-- cleaning data using sql queries

select 
SaleDate
from nashvillehousingdata;

SELECT STR_TO_DATE(SaleDate,'%M %d, %Y') 
from nashvillehousingdata;

update nashvillehousingdata
set SaleDate =  STR_TO_DATE(SaleDate,'%M %d, %Y');

select 
*
from nashvillehousingdata;


-- populate property address data 

select 
*
from nashvillehousingdata
-- where propertyaddress is null
order by parcelid;



select 
a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
from nashvillehousingdata a
JOIN nashvillehousingdata b
	on a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
where a.propertyaddress is null;



-- UPDATE    
update nashvillehousingdata a
JOIN nashvillehousingdata b
	on a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.propertyaddress is null;

-- placing address into individual columns (address, state, city.)
select 
PropertyAddress
from nashvillehousingdata;
-- where propertyaddress is null
-- order by parcelid;

-- attempted use of CHARINDEX however not available in mysql, use Locate instead
select
SUBSTRING(PropertyAddress, 1, locate(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, locate(',', PropertyAddress) +1, length(PropertyAddress) ) as Address
from nashvillehousingdata;


-- adding new columns to our table
Alter table nashvillehousingdata
add PropertySplitAddress Nvarchar(255);

update nashvillehousingdata
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, locate(',', PropertyAddress)-1);

Alter table nashvillehousingdata
add PropertySplitCity Nvarchar(255);

update nashvillehousingdata
SET PropertySplitCity = SUBSTRING(PropertyAddress, locate(',', PropertyAddress) +1, length(PropertyAddress) );

select 
*
from nashvillehousingdata;

-- Alter table nashvillehousingdata
-- drop column PropertySplitAddress;

-- Alter table nashvillehousingdata
-- drop column  PropertySplitCity


--------------------------------------------------------------------------------------------------------------------------------------------
select 
OwnerAddress
from nashvillehousingdata;

-- split ownersdata into address, city and state

-- Select
-- PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
-- ,SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.') , 2)
-- ,
-- PARSENAME(OwnerAddress , 1)
-- FROM nashvillehousingdata;

select
OwnerAddress,
SUBSTRING_INDEX(OwnerAddress, ',',  1)
,SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',',  2), ',', -1)
,SUBSTRING_INDEX(OwnerAddress, ',',  -1)
from nashvillehousingdata;


-- owners address 
Alter table nashvillehousingdata
add OwnerSplitAddress Nvarchar(255);

update nashvillehousingdata
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',',  1);

-- owners city
Alter table nashvillehousingdata
add OwnerSplitCity Nvarchar(255);

update nashvillehousingdata
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',',  2), ',', -1);

-- owners state
Alter table nashvillehousingdata
add OwnerSplitState Nvarchar(255);

update nashvillehousingdata
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',',  -1);

select 
count(*)
from nashvillehousingdata;

--------------------------------------------------------------------------------------------------------------------------------------------
 -- change y and n to yes and no in property sold 
 
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From nashvillehousingdata
Group by SoldAsVacant
order by 2;

select soldasvacant,
case when soldasvacant = 'Y' THEN 'Yes'
	when soldasvacant = 'N' THEN 'No'
    else soldasvacant
    end
From nashvillehousingdata;

update nashvillehousingdata
SET SoldAsVacant = case when soldasvacant = 'Y' THEN 'Yes'
	when soldasvacant = 'N' THEN 'No'
    else soldasvacant
    end;
    
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From nashvillehousingdata
Group by SoldAsVacant
order by 2;

--------------------------------------------------------------------------------------------------------------------------------------------
-- create table identicall incase I mess up
CREATE TABLE NashHouseDub AS
    SELECT *
    FROM  nashvillehousingdata;


-- remove duplicate rows

WITH RowNumCTE as (
select *,
row_number()over(
	partition by ParcelID,
		PropertyAddress,
        SalePrice,
        SaleDate,
        LegalReference
        order by UniqueID
        )
        row_num
        
from nashvillehousingdata
-- order by parcelid
)
select *
from RowNumCTE
where row_num > 1;


-- attempts to find and delete duplicates

-- SELECT 
--     ParcelID, COUNT(ParcelID)
-- FROM
--     nashvillehousingdata
-- GROUP BY 
--     ParcelID
-- HAVING 
--     COUNT(ParcelID) > 1;

-- select * FROM nashvillehousingdata c1
-- INNER JOIN nashvillehousingdata c2 
-- WHERE
--     c1.UniqueID > c2.UniqueID AND 
--     c1.ParcelID = c2.ParcelID;

select *
FROM nashvillehousingdata2 p1
WHERE EXISTS (SELECT 1 FROM NashHouseDub p2
              WHERE p2.ParcelID = p1.ParcelID AND
                    p2.PropertyAddress = p1.PropertyAddress AND
                    p2.SalePrice = p1.SalePrice AND
                    p2.SaleDate = p1.SaleDate AND
                    p2.LegalReference = p1.LegalReference AND
                    p2.UniqueID < p1.UniqueID);
                    
delete 
FROM nashvillehousingdata2 p1
WHERE EXISTS (SELECT 1 FROM NashHouseDub p2
              WHERE p2.ParcelID = p1.ParcelID AND
                    p2.PropertyAddress = p1.PropertyAddress AND
                    p2.SalePrice = p1.SalePrice AND
                    p2.SaleDate = p1.SaleDate AND
                    p2.LegalReference = p1.LegalReference AND
                    p2.UniqueID < p1.UniqueID);
                    
		
-- didnt manage it

-- delete unusable columns

CREATE TABLE nashvillehousingdata2 AS
    SELECT *
    FROM  NashHouseDub;

select 
* 
from nashvillehousingdata1;

alter table nashvillehousingdata1
drop column OwnerAddress;

alter table nashvillehousingdata1
drop column TaxDistrict;

alter table nashvillehousingdata1
drop column PropertyAddress;

-- nashvillehousingdata1 is the cleanest set 