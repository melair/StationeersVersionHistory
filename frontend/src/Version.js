import React, { Component } from 'react';
import moment from 'moment';

class Version extends Component {
  render() {
    var notes = this.props.version.data.notes.map((note, index) => <li key={index}>{note}</li>)

    var beta = null;

    if (this.props.version.data.releases.beta !== undefined) {
      beta = <Tag name="Beta" date={this.props.version.data.releases.beta} />
    }

    var live = null;

    if (this.props.version.data.releases.public !== undefined) {
      live = <Tag name="Live" date={this.props.version.data.releases.public} />
    }

    var built_on = null;
    var built_raw = this.props.version.data.releases.built;

    if (built_raw !== undefined && built_raw !== "unknown") {
      built_on = "(" + moment(built_raw).format('LL') + ")";
    }

    return (
      <div className="Version">
        <h3>{this.props.version.number} {built_on}</h3>
        <div className="Tags">
          {beta}
          {live}
        </div>
        <ul>
          {notes}
        </ul>
      </div>
    );
  }
}

class Tag extends Component {
  render() {
    var title = "Unknown Date";

    if (this.props.date !== "unknown") {
      title = moment(this.props.date).format('LL');
    }

    return (
      <abbr className={"Tag " + this.props.name} title={title}>
        {this.props.name}
      </abbr>
    );
  }
}

export default Version;
