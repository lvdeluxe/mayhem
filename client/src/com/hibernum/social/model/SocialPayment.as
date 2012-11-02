/**
 * Created by IntelliJ IDEA.
 * User: bdupuis
 * Date: 11-07-14
 * Time: 10:48 AM
 * To change this template use File | Settings | File Templates.
 */
package com.hibernum.social.model {
public class SocialPayment {
	public var id:String;
	public var title:String;
	public var description:String;
	public var image_url:String;
	public var product_url:String;
	public var price:int;

	public function SocialPayment() {
	}

	public function toObject():Object {
		return {id:id, title:title, image_url:image_url, product_url:product_url, description:description, price:price};
	}
}
}
