# Nexus Repository

## I. install Nexus Repository:

### 1. centos: `scripts/centos/install-nexus-repository.sh`

### 2. ubuntu: `scripts/ubuntu/install-nexus-repository.sh`

### 3. Amazon linux 2: `scripts/install-nexus-repository.sh`

## II. Nexus console

### 1. change admin password
### 2. Authentication: Login to Nexus
### 3. Authorization: Create `Role` and `Users` for pipeline

**step1: create role**
![authorization-create-role](images/authorization-create-role.png)


**step2: create local user**
![create local user](images/create-local-user.png)

### III. `Repository Type` in Nexus

### 1. Repo Type: `Hosted`

![nexus-hosted-repo](images/nexus-hosted.png)

#### 1.1 `Releases` Repository (Type: `Hosted`)
```
Use Case: Stable Releases

Honestly, our code isn’t always ready for prime-time release. Nexus allows you to separate those releases which are ready to release and which are not. In these types of repositories, you push those builds that are well-tested and designated for further process.
```

### 1.2 `Snapshot` Repository (Type: `Hosted`)
```
Use Case: Continuous Integration and Testing

Snapshots are like works in progress. The snapshot repository in Nexus is where you store evolving versions of your project during development. This is particularly useful for continuous integration, enabling developers to access the latest, potentially unstable, builds for testing purposes.
```

### 1.3 `Hosted` Repository (Type: `Hosted`)
```
Use Case: Your Private Stash

Think of the hosted repository as your personal storage unit within Nexus. It’s where you keep your unique, in-house artifacts that aren’t meant for public consumption. Most of the time you are using Hosted Repositories either it is Snapshot or Release Type.
```

### 2. `Proxy` Repository
![nexus-proxy-repo](images/nexus-proxy-repo.png)

```
- A proxy repository is a repository that is linked to a remote repository.
- Any request for a component is verified against the local content of the proxy repository.
- If no local component is found, the request is forwarded to the remote repository. The component is then retrieved and stored locally in the repository manager, which acts as a cache.
Subsequent requests for the same component are then fulfilled from the local storage, therefore eliminating the network bandwidth and time overhead of retrieving the component from the remote repository again.

Ex: maven-central, npm, Docker, PyPI, yum
```

### 3. `Group` Repository:

![nexus-group-repo](images/nexus-group-repo.png)


## IV: Nexus Version policy:
```
Version Policy:
- Release - Artifacts are expected to be release versions (ie not changing)
- Snapshot - Artifacts are development releases, and are expected to be changing
- Mixed - Combination of Release and Snapshot
```

## V. Create `custom Maven2 Repository` in Nexus

### step-1: create maven2 `snapshot`

![create maven2 snapshot](images/create-maven2-snapshot.png)

### step-2: create maven2 `release`

![create maven2 release](images/create-maven2-release.png)

### step-3: create maven2 `proxy`
![alt text](images/create-maven2-proxy.png)`

### step-4: create maven2 `group`
![create-maven2-group](images/create-maven2-group.png)