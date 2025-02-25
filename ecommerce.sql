

create database Ecommercetask;




create table Product(
Id  int identity(1,1) primary key,
Productname varchar(255) not null,
Productdescription varchar(255)not null,
Productprice decimal(30,2) not null,
Productquantity int not null,
Productcategory varchar(255) not null,
Productimageurl varchar(255) not null

);
go;
CREATE PROCEDURE Addproduct(@Productname varchar(255),@Productdescription varchar(255),
@Productprice decimal(30,2),@Productquantity int,@Productcategory varchar(255),@Productimageurl varchar(255) )
as
begin


INSERT INTO Product(Productname,Productdescription,Productprice,Productquantity,Productcategory,Productimageurl) 
VALUES(@Productname,@Productdescription,@Productprice,@Productquantity,@Productcategory,@Productimageurl);


end


go;
CREATE PROCEDURE Getallproduct
as
begin
begin try
begin transaction
select * from Product;
commit transaction

end try
begin catch
rollback transaction
end catch

end

go;
alter procedure GetProductbyid(@Id int, @Productimageurl  varchar(255) output)
as
begin
SET @ProductImageUrl = NULL;
select @Productimageurl=Productimageurl from Product where Id=@Id;


end






go;
CREATE PROCEDURE DeleteProduct(@Id int)
as
begin
begin try
begin transaction
Delete from Product where Id=@ID;
commit transaction

end try
begin catch
rollback transaction
end catch
end




select * from Product;


delete from Product where Id=1;




create table Customer(
Id int identity(1,1) primary key,
Name varchar(255) not null,
Email varchar(255) not null,
Password  varchar(255) not null,
contactNumber varchar(255)  not null,
Address varchar(255) not null

);

select * from Customer
truncate table Customer
go;


alter table Customer ADD CONSTRAINT uniqueemail   unique (Email);

alter procedure Registercustomer
    @Name varchar(255),
    @Email varchar(255),
    @Password varchar(255),
    @contactNumber varchar(255),
    @Address varchar(255),
    @Message varchar(255) output
as
begin
    if not exists(SELECT * FROM Customer WHERE Email = @Email)
    begin
        insert into Customer(Name, Email, Password, contactNumber, Address)
        values(@Name, @Email, @Password, @contactNumber, @Address);

        set @Message = 'registered successfully.';
    end
    else
    begin
        set @Message = 'Email already exists.';
    end
end





go;
alter procedure Logincustomer
   
    @Email varchar(255),
    @Password varchar(255),
	@Id int output
as
begin
    if  exists(SELECT * FROM Customer WHERE Email = @Email and Password=@Password)
    begin
       select @Id=Id from Customer WHERE Email = @Email and Password=@Password
	   
    end
    else
    begin
        set @Id=0 ;
    end
end



alter procedure GetAllCustomer
as
begin
select Id,Name,Email,contactNumber,Address from Customer;
end

go;
create procedure DeleteUser(@id int)
as
begin

delete from Customer where Id=@id;

end





create table cart(
CartId int identity(1,1) Primary key,
CustomerId int not null foreign key references Customer(Id),
ProductId int not null foreign key references Product(Id),
Quantity int not null ,
Totalamount decimal(30,3)
)


drop table cart;

go;


create procedure inserintocart(@CustomerId int,@ProductId int,@Quantity int=1,@Totalamount decimal(30,3),@Isavailable int output)
as
begin
 IF EXISTS (SELECT 1 FROM cart WHERE CustomerId = @CustomerId AND ProductId = @ProductId)
 begin
 set @Isavailable=1;
 end
else
begin

insert into cart(CustomerId,ProductId,Quantity,Totalamount) values (@CustomerId,@ProductId,@Quantity,@Totalamount);
update Product set Productquantity=Productquantity-@Quantity where Id=@ProductId;
set @Isavailable=0;
end


end


go;
--card
alter procedure Getcartdetail(@Id int)
as
begin

select cart.CartId,cart.Quantity,cart.Totalamount,Customer.Name,Product.Productname,Product.Productdescription,Product.Productprice,Product.Productcategory,Product.Productimageurl
from Customer inner join cart on cart.CustomerId=Customer.Id inner join Product  on cart.ProductId=Product.Id where cart.CustomerId=@Id;

end

GO;
ALTER PROCEDURE AddToCart
    @CartId INT,
    @Quantity INT,
    @Isavailable INT OUTPUT,
    @ActionType VARCHAR(10)
AS
BEGIN
    DECLARE @ProductId INT;
    DECLARE @AvailableStock INT;
    DECLARE @CurrentQuantity INT;

    
    SELECT @ProductId = ProductId, @CurrentQuantity = Quantity
    FROM Cart
    WHERE CartId = @CartId;

    SELECT @AvailableStock = Productquantity
    FROM Product
    WHERE Id = @ProductId;

   
    IF @ActionType = 'ADD'
    BEGIN
       
        IF @AvailableStock >= @Quantity
        BEGIN
            DECLARE @ProductPrice INT;
            SET @ProductPrice = (SELECT Productprice FROM Product WHERE Id = @ProductId);

           
            UPDATE Cart
            SET Quantity = @CurrentQuantity + @Quantity,
                Totalamount = (@CurrentQuantity + @Quantity) * @ProductPrice
            WHERE CartId = @CartId;

          
            UPDATE Product
            SET Productquantity = Productquantity - @Quantity
            WHERE Id = @ProductId;

            SET @Isavailable = 1; 
        END
        ELSE
        BEGIN
            SET @Isavailable = 0; 
        END
    END
   
    ELSE IF @ActionType = 'REMOVE'
    BEGIN
       
        IF @CurrentQuantity >= @Quantity
        BEGIN
          
            UPDATE Cart
            SET Quantity = @CurrentQuantity - @Quantity,
                Totalamount = (@CurrentQuantity - @Quantity) * (SELECT Productprice FROM Product WHERE Id = @ProductId)
            WHERE CartId = @CartId;

            UPDATE Product
            SET Productquantity = Productquantity + @Quantity
            WHERE Id = @ProductId;

        

            SET @Isavailable = 1; 
        END
        ELSE
        BEGIN
            SET @Isavailable = 0;  
        END
    END
    ELSE
    BEGIN
        SET @Isavailable = -1;  
    END
END;


go;
--here
alter procedure gettotle(@id int )
as
begin

select sum(Totalamount) from cart  where CustomerId=@id  group by CustomerId;
end

select * from Customer;
select * from Product;
select * from cart;




create Procedure Deletefromcart(@id int)
as
begin
declare @cardquantity int
declare @productid int
declare @currentinproductauantity int
select  @cardquantity=Quantity,@productid=ProductId from cart where CartId=@id;

select @currentinproductauantity=Productquantity from Product where Id=@productid;
delete from cart where CartId=@id;

update Product set Productquantity=@cardquantity+@currentinproductauantity where Id=@productid;


end




create procedure GetUserByid(@id int)
as
begin

select * from Customer where Id=@id;

end



create procedure Updateuser(
@id int,
@Name varchar(255),
@Email varchar(255),
@Password varchar(255),
@contactNumber varchar(255),
@Address varchar(255))
as
begin

if exists(select 1 from Customer where Id=@id)
begin
update Customer  set Name=@Name,Email=@Email,Password=@Password,contactNumber=@contactNumber,Address=@Address where Id=@id;
end
else
begin
print 'not fount user with this id'
end

end



