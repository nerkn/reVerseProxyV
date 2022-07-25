module main

import vweb
import os
import json
import net.http { CommonHeader, Request, Response, Server, fetch, CommonHeader }

const (	port = 8082)

struct App { 	vweb.Context
  mut:  state shared State}


struct State {
  mut:  cnt int
        processes  []os.Process
  }

struct Redirects{
      from    string
      to     string
  }
fn write_example_config(file_name string) {
  mut k :=  []Redirects{}
  k << Redirects{"localhost",      "localhost:5000"}
  k << Redirects{"localhost:3000", "localhost:5000"}
  os.write_file(file_name, json.encode_pretty(k)) or {println("write problem")}
}
fn read_config(file_name string) []Redirects{
  s := os.read_file(file_name) or {"{error:'read error'}"}
  y := json.decode([]Redirects, s)or {panic("decode problem")}
  println(y)
  return y
}


struct ExampleHandler {
        site_mappings []Redirects
        }

fn (h ExampleHandler) handle(req Request) Response {  
  mut site := req.header.get(CommonHeader.host)or{  'error' }
  println( site )
  /*
  mut found_mappings := Redirects{from:'', to:''}
  for m in h.site_mappings{
    if m.from == site {
    found_mappings = m
    }
  }
  */
  found_mappings := h.site_mappings.filter(fn [site](m Redirects) bool{ return m.from == site })
  
  //println(found_mappings.to +  req.url  )
  println(req)
  println('\n\n\n\n\n\n\n\n\n\n\n\n\n kedi')
  
  mut resp := Response{body:"Site cant found", status_code:404}
  
  resp = http.fetch(http.FetchConfig{
          method: req.method, 
          header: req.header,
          data:   req.data, 
          cookies:req.cookies, //params:req.params, 
          user_agent:req.user_agent,
          //params: req.params,
          url: 'http://'+found_mappings[0].to + req.url }) or {
          //url: 'https://webhook.site/8ea09251-eeeb-47bb-9f9a-08f21e540e21'  }) or {
              println('failed to fetch data from the server')
              return Response{body:"failed", status_code:400}
              }
  
  return resp
}



fn main() {
  println('vweb example')
  file_name := 'config.json' //write_example_config(file_name)
  u := read_config(file_name)
  
	mut server := Server{
		handler: ExampleHandler{site_mappings:u}
	}
	server.listen_and_serve()?
  
}




  //http.fetch(//FetchConfig
  /*
pub mut:
	url                    string
	method                 Method
	header                 Header
	data                   string
	params                 map[string]string
	cookies                map[string]string
	user_agent             string = 'v.http'
	verbose                bool     //
	validate               bool   // set this to true, if you want to stop requests, when their certificates are found to be invalid
	verify                 string // the path to a rootca.pem file, containing trusted CA certificate(s)
	cert                   string // the path to a cert.pem file, containing client certificate(s) for the request
	cert_key               string // the path to a key.pem file, containing private keys for the client certificate(s)
	in_memory_verification bool   // if true, verify, cert, and cert_key are read from memory, not from a file
	allow_redirect         bool = true // whether to allow redirect
}
*/



