Installation
------------

[Deploy pachyderm to AWS](http://pachyderm.readthedocs.io/en/stable/deployment/amazon_web_services.html#deploying-with-an-iam-role)

There is a bug with deploying on aws using iam-roles, which I've reported [here](https://github.com/pachyderm/pachyderm/issues/2878).

Concepts
--------

There are repos, commits, branches, files, datums, jobs, pipelines, logs.
You commit new files. You can list all of the resources as well.
Pipelines run constantly, they constantly transform stuff that you put in them.


Questions:
----------
 - How do you use branching?
 - How does branching interact among different repos? - Irrelevant
 - How does it handle the arrival of multiple new files - pipelines only respond to new commits.
   This is potentially very useful, you only commit at specific times of the day?
 - Does it group the transformations? How does it work? Groups by commits and launches a pachctl job for each new commit all managed by the same pod
 - Can I do all of this stuff from my work laptop?
 - How do you revert to a previous commit? How does this affect existing pipelines? - You can check out individual files from different versions of a commit
   The whole repo never really stays on your side so you have to check out files anyway..
 - Where do the files actually reside? Inside your choice of storage: for me inside S3
 - How do you check the space usage and how much remains etc? Look at your storage store.
 - Are jobs all created in the global namespace? What if you wanted to create a hierarchy of jobs or filter them? Don't know what this means
 - How do you cleanup the contents of a repository? Delete and then garbage collect, this freezes the state of pachctl though and no jobs can run.
  

Notes
-----


Use for us
----------
As new files from bloomberg or any of our datasources come in you transform the input based
With the notion of data branching, you no longer need to use a .not-pushed state, you can watch stuff based on branch names


An interesting idea would be to commit to a different branch and then merge into master.
Or for the productmaster pipeline: each new thing merges to it's own branch which finally gets merged back to master?

Implement the problem of analysing the ivy settlement instants
