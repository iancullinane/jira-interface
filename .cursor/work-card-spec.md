# Godot Work Card Specification

## Application goals

The next goal of this project is the make a new class which can be instantiated.

Right now the query to JIRA only gets the ID and the Summary, I want to keep things like that. However I also want to make a custom resource or some other type to hold that data.

Then there will be a new scene that has a constructor. This has already been created.

## Instructions
- Make a custom resources that is the ID and Summary from the API
- When fetching and generating the scene content, use this type
  - So the GET request gets parsed into the new type
- The new scene accepts a list of these data types and creates its own display
