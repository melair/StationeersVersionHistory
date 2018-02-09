import React, { Component } from 'react';
import Header from './Header';
import History from './History';
import About from './About';

class App extends Component {
  render() {
    return (
      <div className="App">
        <Header />
        <About />
        <History />
      </div>
    );
  }
}

export default App;
