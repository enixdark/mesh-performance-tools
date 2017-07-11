# -*- coding: utf-8 -*-
import sys, os
import yaml
import glob
import subprocess
from optparse import OptionParser
from jinja2 import (Environment, FileSystemLoader, select_autoescape)
from config import CONFIG

env = Environment(autoescape=select_autoescape(
  default_for_string=True,
  default=True,
))
env.loader = FileSystemLoader('.')


"""
generate file for host from jinja2 file
"""
def save(file, number = None):
  
  if number != None:
      avg = int(number) / len(CONFIG['list_ips'])
      i = 0
      for index in range(len(CONFIG['list_ips'])):
          CONFIG['list_ips'][index]['from'] = avg * index
          CONFIG['list_ips'][index]['to'] = avg * (index + 1)
                   
  render = env.get_template(file).render(CONFIG)
  with open(file[:-3],'w') as f:
      f.write(render)

"""
remove file in project
"""
def clean(file):
  os.remove(file)


if __name__ == '__main__':
  opt_parse = OptionParser()
  opt_parse.add_option('-n', '--number', dest = 'number', 
    help = "total request is going to request", default=None)
  params = opt_parse.parse_args()[0]
  save('hosts.j2', params.number)
    
    