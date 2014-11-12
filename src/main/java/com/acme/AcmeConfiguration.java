package com.acme;

import com.ivanceras.commons.conf.Configuration;


/**
 * Sample configuration of your code.
 * All generated classes is places in one thing to simplify setup.
 * @author lee
 *
 */
public class AcmeConfiguration extends Configuration{

	static String baseDirectory =           ".";
	static String daopackageName =          "com.acme.generated.dao";
	static String metaDataPackageName =     "com.acme.generated.dao.meta";
	static String bopackageName =           "com.acme.generated.shared.bo";
	static String mapperpackageName =       "com.acme.generated.dao.mapper";
	static String metaDataDirectory =      "src/main/java";
	static String generatedDirectory =      "src/main/java";
	static String metaDataClassName =       "AcmeMetaData";
	static String columnNames =             "Column"; 

	static String databaseType =        "postgresql";
	static String databaseHost =        "localhost";
	static String databasePort =        "5432";
	static String databaseName =        "acme";
	public static String databaseUser =    "postgres"; 
	static String databasePassword =   "p0stgr3s"; 
	
	static String[] includeSchema = {"public"};
	static Boolean enableCache = false;
	
	static String etcCustomConfigurationFile = "/etc/ivanceras/acme.properties"; //a file use to override your hardcoded settings here
	static Boolean enableRecordChangelog = true;

	public AcmeConfiguration() {
		super(
				baseDirectory,
				daopackageName,
				mapperpackageName,
				bopackageName,
				metaDataPackageName,
				metaDataDirectory,
				generatedDirectory,
				metaDataClassName,
				databaseType,
				databaseHost,
				databasePort,
				databaseName,
				databaseUser,
				databasePassword,
				includeSchema,
				enableCache,
				etcCustomConfigurationFile,
				enableRecordChangelog
		);
		this.useCamelCase = false;
	}
}
