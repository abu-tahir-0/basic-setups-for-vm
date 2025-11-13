#!/bin/bash

# Main Script - System Setup Menu
# Links to all utility scripts

set -e  # Exit on error

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to display menu
show_menu() {
    clear
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}   System Setup & Utilities Menu${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${BLUE}1)${NC} Install Fail2Ban"
    echo -e "${BLUE}2)${NC} Install and Configure Netdata"
    echo -e "${BLUE}3)${NC} Create/Configure Swap File"
    echo -e "${BLUE}4)${NC} Run All Scripts"
    echo -e "${BLUE}5)${NC} Exit"
    echo ""
    echo -e "${GREEN}========================================${NC}"
}

# Function to pause and wait for user
pause() {
    echo ""
    read -p "Press Enter to continue..."
}

# Main loop
while true; do
    show_menu
    read -p "Select an option (1-5): " choice
    
    case $choice in
        1)
            echo -e "\n${YELLOW}Running Fail2Ban installation script...${NC}\n"
            bash "$SCRIPT_DIR/scripts/install_fail2ban.sh"
            pause
            ;;
        2)
            echo -e "\n${YELLOW}Running Netdata installation script...${NC}\n"
            bash "$SCRIPT_DIR/scripts/netdata.sh"
            pause
            ;;
        3)
            echo -e "\n${YELLOW}Running Swap setup script...${NC}\n"
            read -p "Enter swap size in GB (default: 16): " swap_size
            swap_size=${swap_size:-16}
            sudo bash "$SCRIPT_DIR/scripts/swap_maker.sh" "$swap_size"
            pause
            ;;
        4)
            echo -e "\n${YELLOW}Running all scripts...${NC}\n"
            echo -e "${GREEN}Step 1/3: Installing Fail2Ban...${NC}"
            bash "$SCRIPT_DIR/scripts/install_fail2ban.sh"
            echo ""
            echo -e "${GREEN}Step 2/3: Installing Netdata...${NC}"
            bash "$SCRIPT_DIR/scripts/netdata.sh"
            echo ""
            echo -e "${GREEN}Step 3/3: Setting up Swap...${NC}"
            sudo bash "$SCRIPT_DIR/scripts/swap_maker.sh" 16
            echo ""
            echo -e "${GREEN}All scripts completed!${NC}"
            pause
            ;;
        5)
            echo -e "\n${GREEN}Exiting...${NC}"
            exit 0
            ;;
        *)
            echo -e "\n${RED}Invalid option. Please select 1-5.${NC}"
            sleep 2
            ;;
    esac
done
