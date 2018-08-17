import React, { Component } from 'react';

class App extends Component {
  componentWillMount(){
    window.location = "https://stationeering.com/versions/recent";
  }

  render() {
    return (
      <div className="App">
        <h1>Redirecting...</h1>
      </div>
    );
  }
}

export default App;
