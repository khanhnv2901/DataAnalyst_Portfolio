/*
	Cleaning data in SQL Queries
*/

select * 
from dbo.NashvilleHousingData

-------------------------------------------------------------------------------------------------------
-- Standardize Date Format
alter table dbo.NashvilleHousingData
add SaleDateConverted Date;

update dbo.NashvilleHousingData
set SaleDateConverted = Convert(date, SaleDate)

---
select SaleDateConverted, CONVERT(Date, SaleDate)
from dbo.NashvilleHousingData

-------------------------------------------------------------------------------------------------------
-- Populate Provery Address Data
select ParcelID,PropertyAddress
from dbo.NashvilleHousingData
--where PropertyAddress is null

-- xem qua data sẽ thấy rằng ParcelID có duplicate
-- mà cái dup này sẽ có địa chỉ Property giống nhau
-- nên chỗ nào null thì sẽ được ghi địa chỉ dựa vào địa chỉ của ParcelID kia
-- ham check 
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
		ISNULL(a.PropertyAddress, b.PropertyAddress)
from dbo.NashvilleHousingData a
JOIN dbo.NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

-- ham populate gia tri
update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from dbo.NashvilleHousingData a
JOIN dbo.NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

-------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
--ex: 2901  BRANCH CT, NASHVILLE

select PropertyAddress
from dbo.NashvilleHousingData

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
		SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as State
from dbo.NashvilleHousingData

--- Function
alter table dbo.NashvilleHousingData
add PropertySplitAddress nvarchar(255);

update dbo.NashvilleHousingData
set PropertySplitAddress =  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

alter table dbo.NashvilleHousingData
add PropertySplitCity nvarchar(255);

update dbo.NashvilleHousingData
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

-- check
select * 
from dbo.NashvilleHousingData

-- another ways
-- using for OwnerAddress (Address, City, State)
select OwnerAddress
from dbo.NashvilleHousingData
--where OwnerAddress is null

-- test
select PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) 
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from dbo.NashvilleHousingData

-- function
alter table dbo.NashvilleHousingData
add OwnerSplitAddress nvarchar(255),
	OwnerSplitCity nvarchar(255),
	OwnerSplitState nvarchar(255);

update dbo.NashvilleHousingData
set OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- check
select * 
from dbo.NashvilleHousingData

-------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in SoldAsVacant
--check
select Distinct(SoldAsVacant), count(SoldAsVacant)
from dbo.NashvilleHousingData
group by SoldAsVacant	
order by 2


-- test
select SoldAsVacant,
	CASE when SoldAsVacant='Y' THEN 'Yes'
	when SoldAsVacant='N' THEN 'No'
	ELSE SoldAsVacant
	END
from dbo.NashvilleHousingData

-- function
update dbo.NashvilleHousingData
set SoldAsVacant=
	CASE when SoldAsVacant='Y' THEN 'Yes'
	when SoldAsVacant='N' THEN 'No'
	ELSE SoldAsVacant
	END
from dbo.NashvilleHousingData

-------------------------------------------------------------------------------------------------------
-- Remove dupicates

-- delete
WITH RowNumCTE AS(
select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice, 
				SaleDate,
				LegalReference
				ORDER By UniqueID
				) as row_num
from dbo.NashvilleHousingData
--order by ParcelID
)
DELETE
--select *  
from RowNumCTE
where row_num >1

-------------------------------------------------------------------------------------------------------
--Delete Unused Columns

select * 
from dbo.NashvilleHousingData

--ALTER TABLE dbo.NashvilleHousingData
--DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

-------------------------------------------------------------------------------------------------------



















