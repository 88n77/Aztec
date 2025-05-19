echo -e "${BLUE}Deleted nodes Aztec...${NC}"
docker stop aztec-sequencer
docker rm aztec-sequencer

rm -rf "$HOME/my-node/node/"*
rm -rf $HOME/aztec-sequencer