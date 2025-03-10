#!/bin/bash

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Define the path to your audiobook-creator directory
# CHANGE THIS to your actual path
AUDIOBOOK_DIR="$HOME/Documents/Github/audiobook-creator"

# Check if Docker Desktop is running
echo -e "${BLUE}Checking if Docker is running...${NC}"
if ! docker info > /dev/null 2>&1; then
    echo -e "${YELLOW}Docker is not running. Please start Docker Desktop first.${NC}"
    echo -e "${YELLOW}Open Docker Desktop from your Applications folder.${NC}"
    echo -e "${YELLOW}Press Enter once Docker Desktop is running...${NC}"
    read
fi

# Check again if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Docker is still not running. Please start Docker Desktop and try again.${NC}"
    exit 1
fi
echo -e "${GREEN}Docker is running!${NC}"

# Start Kokoro TTS Docker container in the background
echo -e "${BLUE}Starting Kokoro TTS service...${NC}"
CONTAINER_ID=$(docker ps -q --filter "publish=8880")
if [ -z "$CONTAINER_ID" ]; then
    echo -e "${YELLOW}Starting new Kokoro TTS container...${NC}"
    docker run -d -p 8880:8880 ghcr.io/remsky/kokoro-fastapi-cpu:v0.2.2
else
    echo -e "${GREEN}Kokoro TTS container is already running.${NC}"
fi

# Wait for Kokoro to initialize
echo -e "${BLUE}Waiting for Kokoro TTS to initialize...${NC}"
sleep 5

# Verify Kokoro is responding
if curl -s http://localhost:8880/health > /dev/null; then
    echo -e "${GREEN}Kokoro TTS service is running!${NC}"
else
    echo -e "${YELLOW}Waiting for Kokoro TTS to start...${NC}"
    sleep 10
    if curl -s http://localhost:8880/health > /dev/null; then
        echo -e "${GREEN}Kokoro TTS service is running!${NC}"
    else
        echo -e "${RED}Cannot connect to Kokoro TTS. Please check Docker logs.${NC}"
        echo -e "${YELLOW}You may need to run: docker logs $(docker ps -q --filter 'publish=8880')${NC}"
    fi
fi

# Remind user to start LM Studio
echo -e "${YELLOW}IMPORTANT: Please make sure LM Studio is running with server started:${NC}"
echo -e "${YELLOW}1. Open LM Studio${NC}"
echo -e "${YELLOW}2. Load your model${NC}"
echo -e "${YELLOW}3. Go to Local Server tab${NC}"
echo -e "${YELLOW}4. Click 'Start Server'${NC}"
echo -e "${YELLOW}5. Verify your .env file has the correct API URL${NC}"
echo

# Activate the Python virtual environment and open the project directory
echo -e "${BLUE}Activating Python environment...${NC}"
cd "$AUDIOBOOK_DIR" || { echo -e "${RED}Cannot find audiobook directory. Please update the AUDIOBOOK_DIR variable in this script.${NC}"; exit 1; }
source .venv_py312/bin/activate

# Display available commands
echo -e "${GREEN}Ready to use Audiobook Creator!${NC}"
echo -e "${BLUE}Available commands:${NC}"
echo -e "  ${GREEN}python book_to_txt.py${NC} - Convert a book to text format"
echo -e "  ${GREEN}python identify_characters_and_output_book_to_jsonl.py${NC} - Identify characters (for multi-voice)"
echo -e "  ${GREEN}python generate_audiobook.py${NC} - Create the audiobook"
echo

# Start a new shell in the environment
echo -e "${BLUE}Starting a shell in the environment. Type 'exit' to quit.${NC}"
exec $SHELL
