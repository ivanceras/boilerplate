package com.acme;

import java.util.UUID;

import com.acme.generated.dao.DAO_Product;
import com.acme.generated.dao.mapper.ProductMapper;
import com.acme.generated.dao.meta.TableColumns.product;
import com.acme.generated.shared.bo.Product;
import com.ivanceras.db.api.EntityManager;
import com.ivanceras.db.shared.Filter;
import com.ivanceras.db.shared.exception.DatabaseException;

public class ProductController {
	
	public static void main(String[] args){
		EntityManager em = null;
		String productId = "4916cdf5-2a3c-4ccf-9285-1cbc78d24a6d";
		try {
			em = EMF.get();
			//calling a simple controller method
			listProducts(em);
			productInfo(em, productId);
			
			//calling a simple service method
			Product product = productInfoService(productId);
			System.out.println("service call -> product: "+product);
		} catch (DatabaseException e) {
			e.printStackTrace();
		} catch (ServiceException e) {
			e.printStackTrace();
		}
		finally{
			EMF.release(em);
		}
	}

	private static void listProducts(EntityManager em) throws DatabaseException {
		DAO_Product[] products = em.getAll(DAO_Product.class);
		for(DAO_Product product : products){
			System.out.println(product);
		}
	}
	
	private static DAO_Product productInfo(EntityManager em, String productId) throws DatabaseException{
		DAO_Product daoProduct = em.getOne(DAO_Product.class, 
				new Filter(product.product_id, Filter.EQUAL, UUID.fromString(productId)));
		System.out.println("product info: "+daoProduct);
		System.out.println("Product Name: "+daoProduct.getName());
		return daoProduct;
	}
	
	
	/**
	 * A sample method when exposing the controller method to a web service
	 * 
	 * @param productId
	 * @return
	 * @throws ServiceException
	 */
	public static Product productInfoService(String productId) throws ServiceException{
		EntityManager em = null;
		try {
			em = EMF.get();
			DAO_Product daoProduct = productInfo(em, productId);
			return ProductMapper.map(daoProduct);// 
		} catch (DatabaseException e) {
			e.printStackTrace();
			throw new ServiceException(e.getMessage());
		}
		finally{
			EMF.release(em);
		}
	}

}
