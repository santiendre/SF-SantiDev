import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRepos from '@salesforce/apex/GitHubFavoriteController.getRepos';
import saveFavorite from '@salesforce/apex/GitHubFavoriteController.saveFavorite';

export default class GithubExplorer extends LightningElement {
  repos;
  selectedRepo;
  isLoading = false;

  handleSearch(e) {
    this.isLoading = true;
    this.selectedRepo = null;
    getRepos({ username: e.detail })
      .then(result => {
        this.repos = result;
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

  handleRepoFavorite(e) {
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
    })
    .catch(error => {
      this.dispatchEvent(new ShowToastEvent({
        title: 'Error saving favorite',
        message: error.body.message,
        variant: 'error'
      }))
    })
  }
}