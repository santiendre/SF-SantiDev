import { LightningElement, api } from 'lwc';

export default class GithubRepoList extends LightningElement {
  @api repos;

  handleRepoSelect(e) {
    this.dispatchEvent(new CustomEvent('reposelect', { detail: e.detail }));
  }

  handleRepoFavorite(e) {
    this.dispatchEvent(new CustomEvent('repofavorite', { detail: e.detail }));
  }
}