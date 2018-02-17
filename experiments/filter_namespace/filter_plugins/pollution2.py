#! /usr/bin/env python

gn = ['pollution2.py', dir(), __file__, __name__, __package__]

def pollution(unused):
    return gn

class FilterModule(object):

    def filters(self):
        return { 'pollution2': pollution }
