import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { MessageContext, publish } from 'lightning/messageService';
import GITHUB_SEARCH_CHANNEL from '@salesforce/messageChannel/GitHubSearch__c';
import getRepos from '@salesforce/apex/GitHubFavoriteController.getRepos';
import saveFavorite from '@salesforce/apex/GitHubFavoriteController.saveFavorite';
import getFavorites from '@salesforce/apex/GitHubFavoriteController.getFavorites';
import removeFavorite from '@salesforce/apex/GitHubFavoriteController.removeFavorite';
import publishSearchEvent from '@salesforce/apex/GitHubFavoriteController.publishSearchEvent';

export default class GithubExplorer extends LightningElement {
  repos;
  selectedRepo;
  isLoading = false;
  isLoadingFavorites = false;
  favorites;

  columns = [
      { label: 'Name', fieldName: 'name', type: 'text'  },
      { label: 'Owner', fieldName: 'owner', type: 'text' },
      { label: 'Description', fieldName: 'description', type: 'text' },
      { label: 'URL', fieldName: 'url', type: 'url' },
      { type: 'action', typeAttributes: { rowActions: [{ label: 'Remove', name: 'remove' }]}}
  ];

  @wire(getFavorites)
  wiredFavorites(result) {
    this.wiredFavoritesResult = result;
    if(result.data) {
      this.favorites = result.data;
    } else {
      console.error(result.error);
    }
  }

  @wire(MessageContext)
  messageContext;

  get hasFavorites() {
    return this.favorites && this.favorites.length > 0;
  }

  handleSearch(e) {
    this.isLoading = true;
    this.selectedRepo = null;
    const username = e.detail;
    getRepos({ username: username })
      .then(result => {
        this.repos = result;
        publish(this.messageContext, GITHUB_SEARCH_CHANNEL, { username: username });
        publishSearchEvent({ username: username })
          .then(() => console.log('Search event published for:', username))
          .catch(error => console.error('Error publishing search event:', error));
      })
      .catch(error => {
        this.dispatchEvent(new ShowToastEvent({
          title: 'Error fetching repos',
          message: error.body.message,
          variant: 'error'
        }));
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  handleRepoSelect(e) {
    this.selectedRepo = e.detail;
  }

  handleDetailsGoBack() {
    this.selectedRepo = null;
  }

  handleRepoFavorite(e) {
    this.isLoading = true;
    const repo = e.detail;
    saveFavorite({
      name: repo.name,
      owner: repo.owner,
      description: repo.description,
      url: repo.url,
      stars: repo.stars
    })
    .then(result => {
      const message = result ? 'Repo saved to favorites!' : 'Already saved in favorites';
      const variant = result ? 'success' : 'warning';
      this.dispatchEvent(new ShowToastEvent({
        title: message,
        variant: variant
      }));
      refreshApex(this.wiredFavoritesResult);
    })
    .catch(error => {
      this.dispatchEvent(new ShowToastEvent({
        title: 'Error saving favorite',
        message: error.body.message,
        variant: 'error'
      }))
    })
    .finally(() => {
      this.selectedRepo = false;
      this.isLoading = false;
    })
  }

  handleRowAction(e) {
    const actionName = e.detail.action.name;
    const row = e.detail.row;
    if(actionName === 'remove') {
        this.handleRemoveFavorite(row.id, row.name);
    }
  }

  handleRemoveFavorite(recordId, repoName) {
    this.isLoadingFavorites = true;
    removeFavorite({ 
      recordId: recordId,
      repoName: repoName 
    })
    .then(() => {
      refreshApex(this.wiredFavoritesResult)
    })
    .catch(error => {
      const message = error?.body?.message ?? error?.message ?? 'Unknown error';
      this.dispatchEvent(new ShowToastEvent({
        title: 'Error removing favorite',
        message: message,
        variant: 'error'
      }));
    })
    .finally(() => {
      this.isLoadingFavorites = false;
    })
  }
}