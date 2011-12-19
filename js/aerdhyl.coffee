---
---
###
#_gaq = _gaq || [];
#_gaq.push ['_setAccount', 'UA-27133411-1'];
#_gaq.push ['_trackPageview'];
#
#(->
#  ga = document.createElement 'script'; 
#  ga.type = 'text/javascript'
#  ga.async = true
#  ga.src = 'http://www.google-analytics.com/ga.js'
#  s = document.getElementsByTagName('script')[0]
#  s.parentNode.insertBefore ga, s)()
###



disqus_shortname = 'aerdhyl'

(->
  s = document.createElement('script')
  s.async = true
  s.type = 'text/javascript'
  s.src = 'http://' + disqus_shortname + '.disqus.com/count.js'
  (document.getElementsByTagName('HEAD')[0] || document.getElementsByTagName('BODY')[0]).appendChild(s)
)()
