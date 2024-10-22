public class JsonParserProduct {

    public List<Product> products   {get;set;}
    public Integer skip             {get;set;}
    public Integer limit_x          {get;set;}
    public Integer total            {get;set;}
    
    public class Review{
        public Integer rating       {get;set;}
        public String reviewerName  {get;set;}
        public String date_x        {get;set;}
        public String reviewerEmail {get;set;}
        public String comment       {get;set;}
    }

    public class Product{
        public String availabilityStatus    {get;set;}
        public String warrantyInformation   {get;set;}
        public Dimensions dimensions        {get;set;}
        public String shippingInformation   {get;set;}
        public String returnPolicy          {get;set;}
        public List<Review> reviews         {get;set;}
        public Integer minimumOrderQuantity {get;set;}
        public Integer weight               {get;set;}
        public Integer stock                {get;set;}
        public Decimal rating               {get;set;}
        public List<String> tags            {get;set;}
        public Decimal discountPercentage   {get;set;}
        public String brand                 {get;set;}
        public Decimal price                {get;set;}
        public String sku                   {get;set;}
        public String category              {get;set;}
        public Meta meta                    {get;set;}
        public String description           {get;set;}
        public List<String> images          {get;set;}
        public String title                 {get;set;}
        public String thumbnail             {get;set;}
        public Integer id                   {get;set;}
    }

    public class Meta{
        public String createdAt {get;set;}
        public Decimal barcode   {get;set;}
        public String qrCode    {get;set;}
        public String updatedAt {get;set;}
    }

    public class Dimensions{
        public Decimal depth    {get;set;}
        public Decimal height   {get;set;}
        public Decimal width    {get;set;}
    }
}