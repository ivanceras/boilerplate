package com.acme;

import com.ivanceras.db.api.EntityManager;
import com.ivanceras.db.server.util.DAOGenerator;
import com.ivanceras.db.shared.exception.DatabaseException;

public class AcmeCodeGenerator {

	public static void main(String[] args){
		EntityManager em = null;
		try {
			em = SimpleEMF.get(null);
			AcmeConfiguration conf = new AcmeConfiguration();
			new DAOGenerator(em, conf, null, null, true).start();
		} catch (DatabaseException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		}
		finally{
			SimpleEMF.release(em);
		}
	}
}
