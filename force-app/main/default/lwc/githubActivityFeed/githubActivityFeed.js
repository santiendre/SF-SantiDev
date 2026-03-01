import { LightningElement } from 'lwc';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';

export default class GithubActivityFeed extends LightningElement {
  activities = [];
  subscription;
  channelName = '/event/GitHub_Activity__e';
  
  connectedCallback() {
    this.subscription = subscribe(this.channelName, -1, (message) => this.handleMessage(message));
    onError(error => this.handleError(error));
  }

  disconnectedCallback() {
    unsubscribe(this.subscription);
    this.subscription = null;
  }

  get hasActivities() {
    return this.activities && this.activities.length > 0;
  }

  handleMessage(message) {
    const newActivity = {
      id: message.data.event.replayId,
      action: message.data.payload.Action_Type__c,
      value: message.data.payload.User_Repo_Name__c,
      time: message.data.payload.CreatedDate
    };
    this.activities = [newActivity, ...this.activities].slice(0, 10);
  }

  handleError(error) {
    console.error(error);
  }
}