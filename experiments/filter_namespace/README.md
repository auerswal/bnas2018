# Filter Namespace in Ansible

Ivan Pepelnjak wondered if using function definitions outside of the
`FilterModule` class of
[Ansible filter plugins](https://docs.ansible.com/developing_plugins.html)
would pollute the global namespace. He went as far as contacting
[Jon Langemak](http://www.dasblinkenlichten.com/test/) regarding his
blog post
[Creating your own Ansible filter plugins](http://www.dasblinkenlichten.com/creating-ansible-filter-plugins/)
and suggesting he move the function definitions inside the `FilterModule`
class that is needed for all Ansible filter plugins. I had wondered about
this as well, deciding to add a prefix to all my functions used inside a
filter plugin. I added the same prefix to the actual filter names as returned
by `FilterModule.filters()`, which avoids name clashes with official or
other third party filters.

Thinking a bit more about the problem I reasoned that each file included
as a source of filter plugins constitutes a separate namespace. This is
actually required for having each file define a class and method of exactly
the same name, but returning different data.

Anyway, to actually check this I created two filter plugin files,
[pollution.py](filter_plugins/pollution.py) defining the filter `pollution`,
and [pollution2.py](filter_plugins/pollution2.py) defining `pollution2`.
A simple playbook, [`show_namespace.yaml`](show_namespace.yaml), uses the
[debug](http://docs.ansible.com/ansible/latest/debug_module.html) module to
show what the filters return. If they would somehow live in the same namespace,
they would return some overlapping data (and might not even work correctly,
because the function name used in both filter plugins is identical). That
is not the case, confirming my assumption that there is no risk of global
namespace pollution by defining functions at file level for Ansible filter
plugins.

## `ansible-playbook` Output

```
(ansible)$ ansible-playbook show_namespace.yaml 

PLAY [Get and print namespace of Ansible filter plugin] ************************

TASK [Namespace of pollution.py] ***********************************************
ok: [P1.lab.local] => {
    "msg": [
        "pollution.py", 
        [
            "__builtins__", 
            "__doc__", 
            "__file__", 
            "__name__", 
            "__package__"
        ], 
        "/home/auerswald/work/bnas2018/bnas2018-solutions/experiments/filter_namespace/filter_plugins/pollution.py", 
        "ansible.plugins.filter.pollution", 
        null
    ]
}

TASK [Namespace of pollution2.py] **********************************************
ok: [P1.lab.local] => {
    "msg": [
        "pollution2.py", 
        [
            "__builtins__", 
            "__doc__", 
            "__file__", 
            "__name__", 
            "__package__"
        ], 
        "/home/auerswald/work/bnas2018/bnas2018-solutions/experiments/filter_namespace/filter_plugins/pollution2.py", 
        "ansible.plugins.filter.pollution2", 
        null
    ]
}

PLAY RECAP *********************************************************************
P1.lab.local               : ok=2    changed=0    unreachable=0    failed=0   
```

---

[BNAS2018 GitHub repository](https://github.com/auerswal/bnas2018) | [My GitHub user page](https://github.com/auerswal) | [My home page](https://www.unix-ag.uni-kl.de/~auerswal/)
