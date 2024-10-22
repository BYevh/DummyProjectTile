public with sharing class DummyProductMapping {
    
    public static String changeReservedWords(String responseBody) {
        responseBody = responseBody.replace('"limit":', '"limit_x":');
        responseBody = responseBody.replace('"date":', '"date_x":');
        return responseBody;
    }

    public static Product__c mapProductFields(JsonParserProduct.Product product) {
        Product__c newProduct = new Product__c();
        newProduct.Availability_Status__c       = product.availabilityStatus;
        newProduct.Warranty_Information__c      = product.warrantyInformation;
        newProduct.Shipping_Information__c      = product.shippingInformation;
        newProduct.Return_Policy__c             = product.returnPolicy;
        newProduct.Minimum_Order_Quantity__c    = product.minimumOrderQuantity;
        newProduct.Weight__c                    = product.weight;
        newProduct.Stock__c                     = product.stock;
        newProduct.Rating__c                    = product.rating;
        newProduct.Discount_Percentage__c       = product.discountPercentage;
        newProduct.Brand__c                     = String.isEmpty(product.brand) ? 'None' : product.brand;
        newProduct.Price__c                     = product.price;
        newProduct.Sku__c                       = product.sku;
        newProduct.Category__c                  = product.category;
        newProduct.Meta_Created_at__c           = parseDateTime(product.meta.createdAt);
        newProduct.Meta_Barcode__c              = product.meta.barcode;
        newProduct.Meta_Qr_Code__c              = product.meta.qrCode;
        newProduct.Meta_Updated_at__c           = parseDateTime(product.meta.updatedAt);
        newProduct.Description__c               = product.description;
        newProduct.Name                         = product.title;
        newProduct.Thumbnail__c                 = product.thumbnail;
        newProduct.Dummy_ID__c                  = product.id;
        newProduct.Dimensions_width__c          = product.dimensions != null ? product.dimensions.width : null;
        newProduct.Dimensions_height__c         = product.dimensions != null ? product.dimensions.height : null;
        newProduct.Dimensions_depth__c          = product.dimensions != null ? product.dimensions.depth : null;
        newProduct.Tags__c                      = product.tags != null ? String.join(new List<String>(product.tags), ';') : null;
        
        fillImgUrls(product.images, newProduct);
        return newProduct;
    }

    public static List<Review__c> mapReviews(List<JsonParserProduct.Review> reviews, String productSku) {
        List<Review__c> reviewList = new List<Review__c>();
        for (JsonParserProduct.Review review : reviews) {
            Review__c newReview = new Review__c();
            newReview.Rating__c = review.rating;
            newReview.Name = review.reviewerName;
            newReview.Date_time__c = parseDateTime(review.date_x);
            newReview.Email__c = review.reviewerEmail;
            newReview.Comment__c = review.comment;
            newReview.Product_Sku__c = productSku;

            reviewList.add(newReview);
        }
        return reviewList;
    }

    public static DateTime parseDateTime(String dateTimeString) {
        try {
            return (DateTime) JSON.deserialize('"' + dateTimeString + '"', DateTime.class);
        } catch (Exception ex) {
            return null;
        }
    }

    public static void fillImgUrls(List<String> listImgs, Product__c newProduct) {
        Integer sizeListImg = listImgs.size();
        if (sizeListImg >= 1) newProduct.Image_1__c = listImgs.get(0);
        if (sizeListImg >= 2) newProduct.Image_2__c = listImgs.get(1);
        if (sizeListImg >= 3) newProduct.Image_3__c = listImgs.get(2);
        if (sizeListImg >= 4) newProduct.Image_4__c = listImgs.get(3);
        if (sizeListImg >= 5) newProduct.Image_5__c = listImgs.get(4);
        if (sizeListImg >= 6) newProduct.Image_6__c = listImgs.get(5);
    }
    
}