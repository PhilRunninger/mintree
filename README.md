# MinTree

A minimalist version of [NERDTree](https://github.com/scrooloose/nerdtree)

## Pseudocode Ramblings
```
Line 1: '0' + path given (or pwd)
let x = split(system('ls ' . path (or pwd)), '\n')
let indent = (column 1 of previous line) + 1
let prefix = indent . repeat(indent*2, ' ') for files, or
             indent . '▶' . repeat(indent*2 -1, ' ') for dirs
call map(x, 'prefix.v:val')
call append(1, x)

setlocal readonly nomodifiable
setlocal nofoldenable foldcolumn=0 nonumber
setlocal nowrap nolist virtualedit=all sidescrolloff=0
augroup HideMetaColumns
    autocmd!
    " To hide first N columns:                                N                     N
    "                                                         |                     |
    autocmd CursorMoved MinTree if 1+virtcol('.')-wincol() <= 5 | execute 'normal! 05zl' | endif
augroup END

generalize and refactor for opening a folder.
```

## Sample Trees
```
0ABCD/Users/prunninger/projects                                  /Users/prunninger/projects   ═─╞│├└   /Users/prunninger/projects  
1ABCD▸ AllAlgorithmsErlang                                       ╞═AllAlgorithmsErlang                 ╞ AllAlgorithmsErlang       
1ABCD▸ CyaraAutomation                                           ╞═CyaraAutomation                     ╞ CyaraAutomation           
1ABCD▸ DeveloperUtilities                                        ╞═DeveloperUtilities                  ╞ DeveloperUtilities        
1ABCD▸ KATAS                                                     ╞═KATAS                               ╞ KATAS                     
1ABCD▾ PinewoodDerby                                             ╞═PinewoodDerby                       ╞ PinewoodDerby             
2ABCD    README.md                                               │ ├─README.md                         │ ├ README.md              
2ABCD  ▸ VB6                                                     │ ╞═VB6                               │ ╞ VB6                    
2ABCD    generator.erl                                           │ ├─generator.erl                     │ ├ generator.erl          
2ABCD    tags                                                    │ └─tags                              │ └ tags                   
1ABCD▸ RPN                                                       ╞═RPN                                 ╞ RPN                       
1ABCD▾ SPIKES                                                    ╞═SPIKES                              ╞ SPIKES                    
2ABCD  ▾ FoodTrucks                                              │ ╞═FoodTrucks                        │ ╞ FoodTrucks             
3ABCD      Dockerfile                                            │ │ ├─Dockerfile                      │ │ ├ Dockerfile          
3ABCD      README.md                                             │ │ ├─README.md                       │ │ ├ README.md           
3ABCD      aws-compose.yml                                       │ │ ├─aws-compose.yml                 │ │ ├ aws-compose.yml     
3ABCD      docker-compose.yml                                    │ │ ├─docker-compose.yml              │ │ ├ docker-compose.yml  
3ABCD      flask-app                                             │ │ ├─flask-app                       │ │ ├ flask-app           
3ABCD      setup-aws-ecs.sh                                      │ │ ├─setup-aws-ecs.sh                │ │ ├ setup-aws-ecs.sh    
3ABCD      setup-docker.sh                                       │ │ ├─setup-docker.sh                 │ │ ├ setup-docker.sh     
3ABCD      shot.png                                              │ │ ├─shot.png                        │ │ ├ shot.png            
3ABCD    ▸ utils                                                 │ │ ╘═utils                           │ │ ╘ utils               
2ABCD  ▸ RabbitMQ                                                │ ╞═RabbitMQ                          │ ╞ RabbitMQ               
2ABCD  ▸ bus_route_part_2                                        │ ╞═bus_route_part_2                  │ ╞ bus_route_part_2       
2ABCD  ▸ docker                                                  │ ╞═docker                            │ ╞ docker                 
2ABCD  ▸ docker-curriculum                                       │ ╞═docker-curriculum                 │ ╞ docker-curriculum      
2ABCD  ▸ license_manager                                         │ ╞═license_manager                   │ ╞ license_manager        
2ABCD    tags                                                    │ └─tags                              │ └ tags                   
1ABCD▸ StarTrek                                                  ╘═StarTrek                            ╘ StarTrek                  
1ABCD▸ callback_cloud
1ABCD▸ callback_cloud_test_infrastructure
1ABCD▸ callback_cloud_vagrant
1ABCD  id_rsa
1ABCD▸ rebar_3
1ABCD▾ sipp
2ABCD    1
2ABCD    10
2ABCD    100
2ABCD    1000
2ABCD    10000
2ABCD    1001
2ABCD    1002
2ABCD    1003
2ABCD    1004
2ABCD    1005
2ABCD    1006
2ABCD    1007
2ABCD    1008
...
2ABCD    9994
2ABCD    9995
2ABCD    9996
2ABCD    9997
2ABCD    9998
2ABCD    9999
1ABCD▸ sippy_cup
1ABCD▸ syntaxerl
1ABCD  update_vm.sh
```
