use ecommerce;

-- Display the total number of customers based on gender who have placed orders of worth at least Rs.3000.
select c.cus_name, case when c.cus_gender='F' then 'Female' else 'Male' end as gender,count(*)
from `order` o inner join `customer` c on o.customer_id = c.cus_id
where o.ord_amount>=3000 
group by c.cus_name,c.cus_gender;

-- Display all the orders along with product name ordered by a customer having Customer_Id=2
select o.ord_id, o.ord_date, o.ord_amount,o.customer_id, p.pro_name
from `order` o inner join supplier_pricing sp on o.pricing_id = sp.pricing_id
			   inner join product p on sp.product_id = p.pro_id
where o.customer_id=2;               

-- Display the Supplier details who can supply more than one product. 
select s.*,sp.product_count from supplier s inner join (select supplier_id, count(*) as product_count from supplier_pricing group by supplier_id having count(*)>1) as sp
on s.supp_id = sp.supplier_id
where sp.product_count > 1;

-- Find the least expensive product from each category and print the table with category id, name, product name and price of the product
select c.cat_id, c.cat_name, pro_name,lep.least_price
from supplier_pricing sup inner join product pro on sup.product_id = pro.pro_id 
                          inner join category c on pro.category_id = c.cat_id 
                          inner join (select p.category_id, min(sp.supp_price) as least_price 
	                                    from supplier_pricing sp inner join product p 
									      on sp.product_id = p.pro_id group by p.category_id) as lep
where pro.category_id = lep.category_id and sup.supp_price = lep.least_price;                                         

-- Display the Id and Name of the Product ordered after “2021-10-05”.
select p.pro_id as id, p.pro_name as product_name 
from `order` o inner join supplier_pricing sup on o.pricing_id = sup.pricing_id
               inner join product p on sup.product_id = p.pro_id
where o.ord_date >= '2021-10-05';                
                        
-- Display customer name and gender whose names start or end with character 'A'.
select c.cus_name as customer_name, case when c.cus_gender='F' then 'Female' else 'Male' end as gender 
from customer c
where upper(c.cus_name) like upper('A%') or upper(c.cus_name) like upper('%A');

-- Create a stored procedure to display supplier id, name, rating and Type_of_Service. For Type_of_Service, If rating =5, print “Excellent Service”,If rating >4 print “Good Service”, If rating >2 print “Average Service” else print “Poor Service”.
DROP PROCEDURE IF EXISTS `DisplaySuppliersRating`;

DELIMITER //

CREATE PROCEDURE DisplaySuppliersRating()
BEGIN
select s.supp_id as supplier_id, s.supp_name as supplier_name, r.rat_ratstars as rating, case when r.rat_ratstars=5 then 'Excellent Service' when r.rat_ratstars>4 then 'Good Service'
when r.rat_ratstars>2 then 'Average Service' else 'Poor Service' end as type_of_service
from `order` o inner join supplier_pricing sp on o.pricing_id = sp.pricing_id
               inner join supplier s on sp.supplier_id = s.supp_id
               inner join rating r on o.ord_id = r.order_id;
END //

DELIMITER ;

CALL DisplaySuppliersRating();
