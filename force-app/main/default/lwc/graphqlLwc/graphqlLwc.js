import { LightningElement,wire, track } from 'lwc';
import {gql,graphql} from 'lightning/uiGraphQLApi';

export default class GraphQLAccounts extends LightningElement {
  @track results;
  errors;

  @wire(graphql, {
    query: gql`
      query getOpportunityWithItems( $oppID : ID) {
        uiapi {
          query {
            Opportunity(where: {Id : { eq : $oppID }}) {
              edges {
                node {
                  Id
                  Name {
                    value
                  }
                  StageName{
                    value
                  }
                }
              }
            }
          }
        }
    }`,
    variables : '$variables'
  })
  graphqlQueryResult({ data, errors }) {
    if (data) {
      this.results = data.uiapi.query.Opportunity.edges.map((edge) => edge.node);
      console.log(JSON.stringify(this.results));
    }
    this.errors = errors;
  }

    opportunityId = '';
  fetchClick(){
    this.opportunityId = '006J3000004wdhSIAQ';
  }

  get variables(){
    return {
        oppID : this.opportunityId 
    }
  }
}