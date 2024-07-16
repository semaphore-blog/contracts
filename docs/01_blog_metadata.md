# Blog Metadata

Blog metadata consists of any information related to the blog as a whole. Eg. blog title, description, appearance of the blog homepage... . All these data are put into a `JSON` metadata file and stored on `IPFS` and the file `URI` is stored on-chain and can be changed at any time by the blog `creator`.

## Usage

The `creator` can set/update the `metadata_uri` at any time by calling the following method on the `SemaphoreFactory` contract.

```solidity
function setMetadataUri(
    uint256 _groupId, // semaphore group id of the blog
    string calldata _metadataUri // new ipfs metadata uri to be set
)
```
