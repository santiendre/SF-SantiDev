import { LightningElement, api } from 'lwc';

export default class GithubRepoDetail extends LightningElement {
  @api repo;

  handleGoBack() {
    this.dispatchEvent(new CustomEvent('goback'));
  }

  handleFavorite() {
    this.dispatchEvent(new CustomEvent('savefavorite', { detail: this.repo }));
  }
}