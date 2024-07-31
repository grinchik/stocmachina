# STOCMACHINA

Stocmachina is a fully automated, AI-driven pipeline designed for processing images for upload to photography microstock platforms.


## Key Features

* **AI Vision Capabilities:** Utilizes advanced AI to automatically generate accurate descriptions and relevant keywords for images, enhancing discoverability.
* **AI Upscaling:** Incorporates an AI-powered upscaler to enhance image quality, allowing for up to 4× enlargement without loss of detail.
* **Metadata Optimization:** Cleans up any unnecessary metadata, ensuring that only essential information is retained to protect privacy and reduce file size.
* **Embedded Titles and Keywords:** Automatically embeds descriptive titles and keywords into the final upscaled images, readying them for immediate upload.

The entire process is encapsulated within a container for easy deployment and management.


## Installation and Configuration

Follow these steps to set up the project:

1. Add your OpenAI API key to the configuration directory:

```sh
echo "YOUR_OPENAI_API_KEY" > "config/OPENAI_API_KEY";
```

2. Build the container:

```sh
make build;
```


## Running the Container

To run the project, follow these steps:

1. Start the container:

```sh
make run;
```

2. Connect to the running container using SSH. Replace `CONTAINER_IP_ADDRESS` with the actual IP address of the container. Use port 2201 and `.ssh/stocmachina-key` for SSH authentication:

```sh
ssh CONTAINER_IP_ADDRESS -p 2201 -i .ssh/stocmachina-key;
```


## Usage Instructions

1. Navigate to the working directory:

```sh
cd /stocmachina;
```

2. Create an input directory and upload your input PNG images there:

```sh
mkdir "input";
```

3. Run the processing pipeline:

```sh
make;
```

4. After all input images are processed, download the output images from the `/stocmachina/output` directory.

5. Clean up by deleting the `input`, `workspace`, and `output` directories:

```sh
make clean;
```


## Prompting

https://blog.adobe.com/en/publish/2019/06/18/stock-keywording-tips


## Known issues

1. The OpenAI API endpoint may occasionally respond with an error. If this occurs, delete all files related to the broken image from the `workspace` directory and run `make` again.
