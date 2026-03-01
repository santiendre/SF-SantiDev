import { LightningElement, api } from 'lwc';

export default class GithubRepoCard extends LightningElement {
  @api repo;

  handleSelect() {
    this.dispatchEvent(new CustomEvent('reposelect', { detail: this.repo } ));
  }

  handleFavorite() {
    this.dispatchEvent(new CustomEvent('repofavorite', { detail: this.repo } ));
  }
}