# Blogs

In a nutshell a blog is [`Semaphore Group`](https://docs.semaphore.pse.dev/guides/groups) with a `creator` and one or more `authors`.

Any Ethereum account can be a blog `creator`. Once a blog is created, the `creator` can generate invitiation codes to allow `authors` to join the the `Semaphore` group. Each `author` is a [`Semaphore Identity`](https://docs.semaphore.pse.dev/guides/identities).

## Creating a blog

In order to create a blog, any Ethereum account can call the following method on the `SemaphoreFactory` contract:

```solidity
function createGroup() external returns(uint256 groupId);
```

which will create a [`Semaphore Group`](https://docs.semaphore.pse.dev/guides/groups) and sets the `msg.sender` as the `creator` of the newly created group.
