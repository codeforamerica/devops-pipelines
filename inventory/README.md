# Inventory Collection

Our digital inventory is spread across multiple systems, making it challenging
to get a comprehensive view of our assets. This project aims to consolidate
organizational[^1] inventory data from various sources into a single repository,
enabling easier management, analysis, and increasing visibility.

## Notion

The destination of choice for consolidated inventory data is Notion. Notion
provides a flexible platform for organizing and visualizing information.
Further, it acts as our intranet and central hub for knowledge management,
making it an ideal choice for housing our inventory data.

## Inventories

The following inventories are currently being collected and consolidated:

1. List of approved applications from Trelica

## Configuration

The inventory collection process can be configured using environment variables.

| Name                         | Description                                         | Default | Required | 
|------------------------------|-----------------------------------------------------|---------|----------|
| NOTION_API_TOKEN             | The API token for accessing the Notion API.         | n/a     | Yes      |
| NOTION_SYSTEM_DATA_SOURCE_ID | The ID of the Notion database for system inventory. | n/a     | Yes      |
| TRELICA_CLIENT_ID            | The client ID for accessing the Trelica API.        | n/a     | Yes      |
| TRELICA_CLIENT_SECRET        | The client secret for accessing the Trelica API.    | n/a     | Yes      |     
| LOG_LEVEL                    | The logging level for the application.              | `info`  | No       |

## Usage

> [!NOTE]
> The steps below assume you have a working Ruby environment set up and have
> some basic familiarity with running Ruby scripts.

This project includes a command-line tool to facilitate the operation of the
inventory collection process. To use the tool, follow these steps:

1. Clone the repository to your local machine:

    ```bash
    git clone git@github.com:codeforamerica/devops-pipelines.git
    ```

1. Navigate to the inventory collection directory:

    ```bash
    cd devops-pipelines/inventory
    ```
   
1. Install the required dependencies using Bundler:

    ```bash
    bundle install
    ```
   
1. Run the CLI tool, this should display the available commands:

    ```bash
    ./bin/inventory
    ```
   
1. Run the full inventory collection process:

    ```bash
    ./bin/inventory sync
    ```
   
## GitHub Actions

The inventory collection process is automated using GitHub Actions. The
`inventory.yaml` workflow is configured to run daily, and can be triggered
manually for ad-hoc updates.

[^1]: This project focuses on organizational inventory data, excluding
      project-specific assets that may be more sensitive in nature.
