import React, { Component } from 'react';
import axios from 'axios';
import VersionList from './VersionList';

class History extends Component {
  constructor(props) {
    super(props);
    this.state = {
      message: "Please wait, version list is loading."
    };
  }

  render() {
    var display = null;

    if (this.state.versions) {
      display = <VersionList versions={this.state.versions} />;
    } else {
      display = <Status message={this.state.message} />;
    }

    return (
      <div className="VersionList">
        <h2>Versions</h2>
        {display}
      </div>
    );
  }

  componentDidMount() {
    var versionList = this;

    axios({url: 'https://data.stationeers.melaircraft.net/version.json', method: 'get', responseType: 'json'})
      .then(function(response) {
        versionList.setState({ versions: response.data, message: null })
      })
      .catch(function(error) {
        versionList.setState({ message: "Failed to load version list! " + error })
      });
  }
}

class Status extends Component {
  render() {
    return (
      <div className="Status">
        {this.props.message}
      </div>
    );
  }
}

export default History;
