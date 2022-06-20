'use strict';

const core = require('@actions/core');
const github = require('@actions/github');
const simpleGit = require('simple-git');

class GitLog {
  constructor() {
    this.git = simpleGit();
    this.changeSet = {};
  }

  parseDiff(files) {
    let components = new Set();

    files.forEach(item => {
      const filePath = item.file;
      if (filePath.includes('/')) {
        components.add(filePath.split('/')[0]);
      }
    });

    return Array.from(components);
  }

  async getChanges() {
    try {
      const lkg = core.getInput('LKG-hash');
      const commits = await this.git.log({
        from: lkg,
        to: 'HEAD'
      });
      /*
      {
        all: [
          {
            hash: '63d662688f4894b684144592bd4262be0ad8d4ae',
            date: '2022-06-09T15:17:21-04:00',
            message: 'test',
            refs: '',
            body: '',
            author_name: 'Tim Bai',
            author_email: 'tim.bai@d2l.com'
          },
          ...
        ],
        latest: {
          hash: '628fe769e2cee79425acd0c2cd574f3b20ced81e',
          date: '2022-06-14T15:59:26-04:00',
          message: 'fix',
          refs: 'HEAD -> master, origin/master, origin/HEAD',
          body: '',
          author_name: 'Tim Bai',
          author_email: 'tim.bai@d2l.com'
        },
        total: 4
      }
      */

      for(const commit of commits.all) {
        const diffSummary = await this.git.diffSummary([commit.hash + '^!']);
        /*
        DiffSummary {
          changed: 10,
          deletions: 0,
          insertions: 123,
          files: [
            {
              file: 'avro/schema/schema-1.json',
              changes: 68,
              insertions: 68,
              deletions: 0,
              binary: false
            },
            ...
          ]
        }
        */
        const changedComponents = this.parseDiff(diffSummary.files);

        for (const component of changedComponents) {
          if (!this.changeSet.hasOwnProperty(component)) {
            this.changeSet[component] = [];
          }
          this.changeSet[component].push({
            author: commit.author_name,
            email: commit.author_email,
            message: commit.message
          });
        }

      }

      console.log(this.changeSet);
      core.setOutput('changeSet', JSON.stringify(this.changeSet));
    } catch (error) {
      console.trace(error);
      core.setFailed(error.message);
    }
  }
}

const gitLog = new GitLog();
gitLog.getChanges().then(data => console.log("Completed!"));
