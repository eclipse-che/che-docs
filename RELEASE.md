# Eclipse Che release process

##### 1. Create branch for release preparation and next bugfixes:
* `git branch {branchname} #e.g 7.7.x`
* `git push --set-upstream origin {branchname}`
##### 2. Create PR for switch master to the next development version :
* `git branch set_next_version_in_master_{next_version} #e.g 7.8.0-SNAPSHOT`
* Update parent version : `mvn versions:update-parent  versions:commit -DallowSnapshots=true -DparentVersion={next_version}`
* `git push --set-upstream origin set_next_version_in_master_{next_version}`
* Create PR
##### 3. Merge branch to the `release` branch and push changes, release process will start by webhook:
* `git checkout release`
* `git merge -X theirs {branchname}`
* `git push -f`
##### 4. Close/release staging repository on Nexus 
 https://oss.sonatype.org/#stagingRepositories

 > **Note:** For bugfix release procedure will be similar except creating new branch on first step and update version in master branch
