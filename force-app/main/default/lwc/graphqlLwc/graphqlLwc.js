import { LightningElement,wire, track } from 'lwc';
import {gql,graphql} from 'lightning/uiGraphQLApi';
import { createRecord, updateRecord, deleteRecord } from 'lightning/uiRecordApi';

export default class GraphQLAccounts extends LightningElement {
  @track results;
  errors;
  isLoading = false;
  @track productInfoMap = []

  @wire(graphql, {
    query: gql`
      query getPricebookEntries($codes: [String]) {
        uiapi {
          query {
            PricebookEntry(
              where: {
                Product2: { ProductCode: { in: $codes } },
                Pricebook2Id: { eq: "01s5i0000096Zl9AAE" }
              }
            ) {
              edges {
                node {
                  Id
                  UnitPrice {
                    value
                  }
                  Product2 {
                    Id
                    ProductCode{value}
                  }
                }
              }
            }
          }
        }
      }
    `,
    variables: '$variables'
  })
  pricebookEntryData({ data, errors }) {
    if (data) {
      const edges = data.uiapi.query.PricebookEntry.edges;
      this.productInfoMap = edges.reduce((acc, edge) => {
        const entry = edge.node;
        const code = entry.Product2.ProductCode.value;

        acc[code] = {
          productCode: code,
          product2Id: entry.Product2.Id,
          pricebookEntryId: entry.Id,
          unitPrice: entry.UnitPrice?.value ?? 0
        };

        return acc;
      }, {});
      console.log('✅ PricebookEntry Map:', JSON.stringify(this.productInfoMap));
    }
    if (errors) {
      this.error = errors;
      console.error('❌ GraphQL Errors:', JSON.stringify(errors));
    }
  }
  get variables(){
    return {
        codes : this.screenCodes
    }
  }

  @track screenCodes
  changeScreenCode(){ // Change Screen Codes to fetch Product Data and create pricebookEntryData object
    this.screenCodes = this.objQuoteLineItemSchema.screen2.productCodesOnScreen;
  }

  

  quoteId = '0Q05i000001MiSMCA0'; 
  quoteLineItemData = [
    {
        QuoteId: "0Q05i000001MiSMCA0",
        Product2Id: "01t5i000002jU8OAAU",
        Quantity: 1,
        PricebookEntryId: "01u5i000002mC8NAAU",
        UnitPrice: 5000
    },
    {
        QuoteId: "0Q05i000001MiSMCA0",
        Product2Id: "01t5i000002jU8bAAE",
        Quantity: 1,
        PricebookEntryId: "01u5i000002mC8bAAE",
        UnitPrice: 150000
    },
    {
        QuoteId: "0Q05i000001MiSMCA0",
        Product2Id: "01t5i000002jU8ZAAU",
        Quantity: 1,
        PricebookEntryId: "01u5i000002mC8ZAAU",
        UnitPrice: 35000
    },
    {
        QuoteId: "0Q05i000001MiSMCA0",
        Product2Id: "01t5i000002jU8WAAU",
        Quantity: 1,
        PricebookEntryId: "",
        UnitPrice: 75000
    }
  ];

  handleCreate() {
    console.log(this.quoteId);
    this.isLoading = true;
    const createPromises = this.quoteLineItemData.map(item => {
        const fields = {
            QuoteId: item.QuoteId,
            Product2Id: item.Product2Id,
            Quantity: item.Quantity,
            PricebookEntryId: item.PricebookEntryId,
            UnitPrice: item.UnitPrice
        };

        return createRecord({
            apiName: 'QuoteLineItem',
            fields
        });
    });

    Promise.allSettled(createPromises)
    .then(results => {
        this.isLoading = false;

        const successful = results.filter(r => r.status === 'fulfilled').map(r => r.value);
        const failed = results.filter(r => r.status === 'rejected').map(r => r.reason);

        successful.forEach((res) => {
            console.log('Created QuoteLineItem', res.id);
        });

       
        failed.forEach((err) => {
            console.warn(`Failed [${index + 1}]:`, err.body?.message || err.message);
        });
    })
    .catch(error => {
        this.isLoading = false;
        console.error('Unexpected error during processing:', error);
    });
  }


  objQuoteLineItemSchema = {
    screen2 : {
      productCodesOnScreen : ['GC5020', 'GC1020', 'GC5060'],
      selectedProducts: [
        { code: 'GC5020', unitPrice: 2000 },
        { code: 'GC1020', unitPrice: 120000 } // maybe changed by user
      ],
      existingQuoteLineItems : [
        {
          Id : "0QLJ3000000kOFCOA2",
          QuoteId: "0Q05i000001MiSMCA0",
          Product2Id: "01t5i000002jU8OAAU",
          Quantity: 1,
          PricebookEntryId: "01u5i000002mC8NAAU",
          UnitPrice: 5000,
          Product2 : {
             ProductCode : 'GC1020'
          }
        }
      ],
      toCreate : [
        {
          QuoteId: "0Q05i000001MiSMCA0",
          Product2Id: "01t5i000002jU8bAAE",
          Quantity: 1,
          PricebookEntryId: "01u5i000002mC8bAAE",
          UnitPrice: 150000
        }
      ],
      toUpdate : [
        {
          QuoteId: "0Q05i000001MiSMCA0",
          Product2Id: "01t5i000002jU8OAAU",
          Quantity: 1,
          PricebookEntryId: "01u5i000002mC8NAAU",
          UnitPrice: 1000,
        }
      ],
      toDelete : [],
    },
    screen3 : {} // as follows as screen 2 object structure
  }

  
  processQuoteLineItems(schema, productInfoMap, quoteId, screenName) {
    const {
      productCodesOnScreen = [],
      selectedProducts = [],
      existingQuoteLineItems = []
    } = schema[screenName];
    console.log(`Existing QuoteLineItems - ${JSON.stringify(existingQuoteLineItems)}`);
    console.log(`selectedProducts - ${JSON.stringify(selectedProducts)}`);
    console.log(`productCodesOnScreen - ${JSON.stringify(productCodesOnScreen)}`);
    console.log(`productInfoMap - ${JSON.stringify(productInfoMap)}`);

    // Build map of selected code to its user-input price
    const selectedMap = {};
    selectedProducts.forEach(({ code, unitPrice }) => {
      selectedMap[code] = unitPrice;
    });


    let existingMap = {}; // ProductCode => Existing QuoteLineItem
    existingQuoteLineItems.forEach(qli => {
      const code = qli.Product2?.ProductCode;
      if (code) {
        existingMap[code] = qli;
      }
    });

    console.log(`existingMap - ${JSON.stringify(existingMap)}`);

    // Clear placeholders
    schema[screenName].toCreate = [];
    schema[screenName].toUpdate = [];
    schema[screenName].toDelete = [];

    // Process selected items
    selectedProducts.forEach(product => {
      const info = productInfoMap[product.code];
      if (!info) return; // Skip if not found in pricebook
      const existing = existingMap[product.code];
      if (existing) {
        // Check if price needs update
        if (existing.UnitPrice !== product.unitPrice) {
          schema[screenName].toUpdate.push({
            Id: existing.Id,
            // QuoteId: quoteId,
            // Product2Id: info.product2Id,
            // PricebookEntryId: info.pricebookEntryId,
            // Quantity: 1,
            UnitPrice: product.unitPrice
          });
          console.log('toUpdate -- ')
        }
      } else {
        // this is to create QuotelineItem
        schema[screenName].toCreate.push({
          QuoteId: quoteId,
          Product2Id: info.product2Id,
          PricebookEntryId: info.pricebookEntryId,
          Quantity: 1,
          UnitPrice: product.unitPrice
        });
      }
    });

    //Process deletions
    productCodesOnScreen.forEach(code => {
      if (!(code in selectedMap) && existingMap[code]) {
        schema[screenName].toDelete.push(existingMap[code].Id);
      }
    });
    console.log('schema -- '+JSON.stringify(schema));
  }
    

  handleSync(){
    console.log('start')
    this.processQuoteLineItems(this.objQuoteLineItemSchema, this.productInfoMap, this.quoteId, 'screen2');
    this.syncQuoteLineItemsSequentially('screen2');
  }

  async syncQuoteLineItemsSequentially(screenName) {
    const { toCreate = [], toUpdate = [], toDelete = [] } = this.objQuoteLineItemSchema[screenName];

    try {
      // Create
      for (const item of toCreate) {
        const result = await createRecord({ apiName: 'QuoteLineItem', fields: item });
        console.log(`✅ Created QLI: ${result.id}`);
      }

      // UPDATE
      for (const item of toUpdate) {
        const result = await updateRecord({ fields: item });
        console.log(`🔁 Updated QLI: ${item.Id}`);
      }

      // DELETE
      for (const id of toDelete) {
        await deleteRecord(id);
        console.log(`🗑️ Deleted QLI: ${id}`);
      }

      console.log(' All QuoteLineItem operations completed successfully!');
    } catch (error) {
      console.error(' Error during QLI sync:', JSON.stringify(error));
      // Optional: Show toast or rollback logic here
    }
  }
  
}