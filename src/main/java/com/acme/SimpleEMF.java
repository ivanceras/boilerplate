/*******************************************************************************
 * Copyright by CMIL
 ******************************************************************************/
package com.acme;


import java.util.LinkedList;
import java.util.Queue;

import com.ivanceras.commons.conf.Configuration;
import com.ivanceras.commons.conf.DBConfig;
import com.ivanceras.db.api.EntityManager;
import com.ivanceras.db.api.IDatabase;
import com.ivanceras.db.api.SynchronousEntityManager;
import com.ivanceras.db.server.core.DatabaseManager;
import com.ivanceras.db.shared.exception.DBConnectionException;
import com.ivanceras.db.shared.exception.DatabaseException;

/**
 * This is just a simple version of the EMF, unlike EMF this doesn't involve any generated classes, which would have compile error
 * @author lee
 *
 */

public class SimpleEMF {
	
	static Configuration conf = null;
	static final SimpleEMF singleton = new SimpleEMF();
	static final SimpleEMF getDBPool() {return singleton;}

	//////////////////////////////////
	// SINGLETON STATE VARIABLES
	////////////////////////////////
	
	Queue<IDatabase> pool = new LinkedList<IDatabase>();

	public static EntityManager get() throws DatabaseException{
		return get("");
	}

	
	public static EntityManager get(String token) throws DatabaseException{
		if(conf == null){
			System.out.println("Initializing configuration..... should only be called once");
			conf = new AcmeConfiguration();
		}
		return get(token, conf.getDBConfig());
	}
	
	public static EntityManager get(String token, DBConfig dbconfig) throws DatabaseException{
		IDatabase db = null;
		try {
			db = getDBPool().connectDB(dbconfig);
		} catch (DBConnectionException e) {
			e.printStackTrace();
			throw new DatabaseException(e.getMessage());
		}	
		if(db==null){
			System.err.println("Unable to create Database connection");
			throw new DatabaseException("Unable to create Database connection");
		}

		EntityManager em = (EntityManager) new SynchronousEntityManager(db);
		return em;
	} 
	
	public static Configuration getConfiguration(){
		return conf;
	}
	
	
	public static void release(EntityManager em){
		if(em == null){
			System.err.println("EntityManager is null");
			return;
		}
		IDatabase db = ((SynchronousEntityManager) em).getDB();
		if(db!=null){
			getDBPool().releaseConnection(db);
		}
		else{
			System.err.println("Releasing a null connection.. somethings is not right!");
		} 
		em.resetDB();
	}
	
	/**
	 * The only time to read configurations and files when a new connection is to be made, 
	 * cached connections don't have to read configurations so it would be fast enough
	 * @param conf
	 * @return
	 * @throws DBConnectionException
	 * @throws DatabaseException
	 */
	
	public synchronized IDatabase connectDB(Configuration conf) throws DBConnectionException, DatabaseException
	{
		return connectDB(conf.getDBConfig());
	}
	
	public synchronized IDatabase connectDB(DBConfig dbconfig) throws DBConnectionException, DatabaseException
	{
		IDatabase ret = null;
		int size = pool.size();
		for(int i = 0; i < size; i++){
			IDatabase db = pool.poll();
			if(!db.isClosed() && db.getConfig() != null && db.getConfig().equals(dbconfig)){
				return db;
			}
			else{
				pool.add(db);
			}
		}
		if(ret==null){
			ret = DatabaseManager.create(dbconfig);
		}
		return ret;
	}
	
	public synchronized void releaseConnection(IDatabase db)
	{
		if(db.isClosed()) return;
		db.reset();
		pool.add(db);
	}
}
