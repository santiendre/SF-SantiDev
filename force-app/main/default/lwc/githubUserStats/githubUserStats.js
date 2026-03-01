import { LightningElement, wire } from 'lwc';
import { MessageContext, subscribe, unsubscribe } from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import GITHUB_SEARCH_CHANNEL from '@salesforce/messageChannel/GitHubSearch__c';
import getUserProfile from '@salesforce/apex/GitHubUserController.getUserProfile';

export default class GithubUserStats extends LightningElement {
  userProfile;
  subscription;

  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    this.subscription = subscribe(this.messageContext, GITHUB_SEARCH_CHANNEL, (message) => this.handleMessage(message));
  }

  disconnectedCallback() {
    unsubscribe(this.subscription);
    this.subscription = null;
  }

  handleMessage(message) {
    getUserProfile({ username: message.username })
      .then(result => {
        this.userProfile = result;
      })
      .catch(error => {
        this.dispatchEvent(new ShowToastEvent({
          title: 'Error getting profile',
          message: error.body.message,
          variant: 'error'
        }));
      })
  }
}