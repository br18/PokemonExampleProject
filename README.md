
# Demo iOS Pokemon App

Demonstrating well-tested, clean and modular code with a very simple Pokemon app. This app fetches data from [PokeAPI](https://pokeapi.co/) endpoints.



## Features

- Scrolling list of Pokemon names
- Tap on a Pokemon name to view more details




## Installation

This app has no third party dependencies and should build using Xcode with the "Pokemon" scheme.
    
## Running Tests

Select the "Pokemon" scheme in Xcode and tap Cmd+U to run all tests.

## Architecture

There are modules for the API, List Feature and Details feature, none of which depend on each other. Common UI code and domain objects are shared. The app itself brings the features together with adapters and coordinators.

I was able to write and unit test view controllers and view models independently by using a protocol which defined a generic contract between a view controller and view model. The protocol defines a single reactive state that the view controller consumes and allows the view controller to send actions to the view model. This protocol also enforces a unidirectional data flow in the view layer.
