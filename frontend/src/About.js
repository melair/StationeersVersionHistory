import React, { Component } from 'react';

class About extends Component {
  render() {
    return (
      <div className="About">
        <h2>About</h2>
        <p>At regular intervals <code>rocketstation_data/StreamingAssets/version.ini</code> is checked out from both the stable and beta branch from the Steam depot.</p>
        <p>The data is then parsed to extract release notes per version, it will also track when it sees a new version pushed to a branch. This may differ from the actual release time.</p>
        <h3>Data</h3>
        <p>You may also access the data which makes up this page and two ATOM feeds of the version details. The version JSON file may change if needed in the future.</p>
        <ul>
          <li><a href="//data.stationeers.melaircraft.net/version.json">Version Data (JSON)</a></li>
          <li><a href="//data.stationeers.melaircraft.net/public.atom">Public Version History (ATOM)</a></li>
          <li><a href="//data.stationeers.melaircraft.net/beta.atom">Beta Version History (ATOM)</a></li>
        </ul>
        <h3>Source</h3>
        <p>If you'd like to see the history of version data, or help contribute to this project you can access it at GitHub!</p>
        <ul>
          <li><a href="https://github.com/melair/StationeersVersionHistory">Frontend and Backend Source</a></li>
          <li><a href="https://github.com/melair/StationeersVersionHistoryData">Versioned Version Data</a></li>
        </ul>
        <h3>Credits</h3>
        <p>Any questions, feel free to get in touch.</p>
        <dl>
          <dt>Melair (Discord: <code>Melair#0001</code>)</dt>
          <dd>Initial creation, hosting.</dd>
        </dl>
      </div>
    );
  }
}

export default About;
