import React, { Component } from 'react';
import Version from './Version';

class VersionList extends Component {
  render() {
    var versionNumbers = Object.keys(this.props.versions);

    var versions = versionNumbers
      .map(versionNumber => { return { number: versionNumber, data: this.props.versions[versionNumber] } })
      .map(version => <Version version={version} key={version.number} />);

    return (
      <div className="Versions">
        <p>
          Each version will be tagged with the branch it has been seen on.
        </p>
        {versions}
      </div>
    );
  }
}

export default VersionList;
