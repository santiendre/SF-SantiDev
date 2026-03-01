import { LightningElement } from 'lwc';

export default class GithubSearchBar extends LightningElement {
  username;

  handleUsername(e) {
    this.username = e.target.value;
  }

  handleSearch() {
    this.dispatchEvent(new CustomEvent('search', { detail: this.username }));
  }
}