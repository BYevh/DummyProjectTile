import { LightningElement} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getFilteredDummyProducts from '@salesforce/apex/DummyProductTile.getFilteredDummyProducts';
import makeGetCallout from '@salesforce/apex/DummyProductTile.makeGetCallout';

export default class DummyProductInTile extends NavigationMixin(LightningElement) {
    dproductsFiltered;
    totalDProducts = 0;
    stockSum = 0;
    unitPrice = 0;
    filterBy = "Name";
    filterInputText = "";
    error;
    
    get filterByOptions() {
        return [
            { label: 'Name',        value: 'Name' },
            { label: 'Category',    value: 'Category__c' },
            { label: 'Brand',       value: 'Brand__c' },
            { label: 'Rating',      value: 'Rating__c' },
            { label: 'SKU',         value: 'Sku__c' }
        ]
    }
    
    connectedCallback() {
		this.loadDProducts();
	}

	async loadDProducts() {
        try {
            if (this.filterInputText === "") {
                await makeGetCallout();
            }
                getFilteredDummyProducts({filterField : this.filterBy, searchText : this.filterInputText})
                    .then(result => {
                        this.dproductsFiltered = result;
                        this.totalDProducts = result.length;
                        this.stockSum = 0;
                        this.unitPrice = 0;
                        this.dproductsFiltered.forEach(element => {
                        this.stockSum = this.stockSum + element.Stock__c;
                        this.unitPrice = this.unitPrice + element.Price__c;
                        });
                    });
        } catch (error) {
            this.error = error;
            console.error('Error loading products:', error);
        }
        
	}
    
    navigateToRecord(event) {
        const recordId = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }

    filterbyHandler(event){
        this.filterBy = event.target.value;
    }

    filterHandler(event){
        this.filterInputText = event.target.value;
    }
    
    clickButtonHandler() {
        this.loadDProducts();
    }
}