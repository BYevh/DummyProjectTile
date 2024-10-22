public with sharing class DummyProductTile {

    // Constants for filter field names
    private static final String FIELD_NAME      = 'Name';
    private static final String FIELD_CATEGORY  = 'Category__c';
    private static final String FIELD_BRAND     = 'Brand__c';
    private static final String FIELD_RATING    = 'Rating__c';
    private static final String FIELD_SKU       = 'Sku__c';

    // Business constants
    private static final Integer MAX_PRODUCTS_PER_CATEGORY = 100;
    private static final Decimal MAX_TOTAL_PRICE = 10000;
    private static final Decimal RATING_VARIANCE = 0.25;

    @AuraEnabled
    public static void makeGetCallout(){
        try {
            ProductCallout.makeGetCallout();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(Cacheable=true)
    public static List<Product__c> getFilteredDummyProducts(String filterField, String searchText) {
        List<Product__c> filteredProducts = new List<Product__c>();

        if (String.isNotEmpty(filterField) && String.isNotEmpty(searchText)) {
            if (filterField.equals(FIELD_RATING) && isNumericOrDecimal(searchText)) {
                Decimal searchRating = Decimal.valueOf(searchText);
                filteredProducts = [
                    SELECT Id, Name, Rating__c, Price__c, Brand__c, Stock__c, Sku__c, Thumbnail__c, Description__c, Category__c
                    FROM Product__c 
                    WHERE (Rating__c < :searchRating + RATING_VARIANCE 
                        AND Rating__c > :searchRating - RATING_VARIANCE)
                ]; 
            } else if (filterField.equals(FIELD_NAME) || filterField.equals(FIELD_CATEGORY) || filterField.equals(FIELD_BRAND) || filterField.equals(FIELD_SKU)) {
                String likeSearchText = '%' + searchText + '%';
                String queryString = 'SELECT Id, Name, Rating__c, Price__c, Brand__c, Stock__c, Sku__c, Thumbnail__c, Description__c, Category__c '
                                    + 'FROM Product__c '
                                    + 'WHERE ' + filterField + ' '
                                    + 'LIKE :likeSearchText';
                filteredProducts = Database.query(queryString);
            }
        } else {
            filteredProducts = getAllDummyProducts();
        }
        return applyBusinessLogic(filteredProducts);
    }

    private static List<Product__c> getAllDummyProducts() {
        return [
            SELECT Id, Name, Rating__c, Price__c, Brand__c, Stock__c, Sku__c, Thumbnail__c, Description__c, Category__c
            FROM Product__c
        ];
    }

    @TestVisible
    private static List<Product__c> applyBusinessLogic(List<Product__c> productList) {
        List<Product__c> finalProductList = new List<Product__c>();
        Map<String, List<Product__c>> productsByCategory = new Map<String, List<Product__c>>();
        Decimal totalPrices = 0;

        for (Product__c product : productList) {
            if (productsByCategory.containsKey(product.Category__c) && productsByCategory.get(product.Category__c).size() < MAX_PRODUCTS_PER_CATEGORY) {
                if ((totalPrices + product.Price__c) < MAX_TOTAL_PRICE) {
                    totalPrices += product.Price__c;
                    productsByCategory.get(product.Category__c).add(product);
                    finalProductList.add(product);
                } 
            } else if (!productsByCategory.containsKey(product.Category__c) && (totalPrices + product.Price__c) < MAX_TOTAL_PRICE) {
                totalPrices += product.Price__c;
                productsByCategory.put(product.Category__c, new List<Product__c>{ product });
                finalProductList.add(product);
            }
        }
        return finalProductList;
    }

    public static Boolean isNumericOrDecimal(String input) {
        input = input.contains('.') ? input.replace('.', '') : input;
        return input.isNumeric();
    }
}