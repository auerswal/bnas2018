# Nested Groups in Ansible

Nested groups can be used to define hosts and groups in Ansible, instead
of repeating the host names under group headings as I have done for
[homework 1](../../hw1-the_lab/).

With *nested groups*, the hosts are defined inside what could be called
*leaf groups*.  These *leaf groups* comprise only hosts, and each host
is part of only one *leaf group*.  All *non-leaf groups* comprise only
groups, not hosts.

While this did not reduce the number of lines, it reduced the amount of
repetition and the number of characters for defining the inventory. Thus
using nested groups seems beneficial in reducing the likelihood of errors
due to typos.

```
$ wc */*/inventories/*/hosts
  41   46  831 hw1-the_lab/ansible/inventories/half_lab/hosts
  55   74 1435 hw1-the_lab/ansible/inventories/lab/hosts
  41   46  737 experiments/ansible-nested-groups/inventories/half_lab/hosts
  55   74 1333 experiments/ansible-nested-groups/inventories/lab/hosts
 192  240 4336 total
```

## Links to Hosts Files

* [(full) lab from homework 1](../../hw1-the_lab/ansible/inventories/lab/hosts) inventory
* [(full) lab with nested groups](inventories/lab/hosts) inventory
* [half lab from homework 1](../../hw1-the_lab/ansible/inventories/half_lab/hosts) inventory
* [half lab with nested groups](inventories/half_lab/hosts) inventory

---

[BNAS2018 GitHub repository](https://github.com/auerswal/bnas2018) | [My GitHub user page](https://github.com/auerswal) | [My home page](https://www.unix-ag.uni-kl.de/~auerswal/)
