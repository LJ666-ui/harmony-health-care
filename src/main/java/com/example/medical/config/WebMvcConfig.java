package com.example.medical.config;

import com.example.medical.common.JwtUtil;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import javax.servlet.http.HttpServletRequest;> hvigor ERROR: 00305015 Rollup Error
                                             Error Message: Unexpected token (Note that you need plugins to import files that are not JavaScript)
                                             . At file: E:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets\pages\DoctorFollowUpPage.ets:376
                                             1 ERROR: 10605008 ArkTS Compiler Error
                                             Error Message: Use explicit types instead of "any", "unknown" (arkts-no-any-unknown) At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:357:12


                                             2 ERROR: 10605008 ArkTS Compiler Error
                                             Error Message: Use explicit types instead of "any", "unknown" (arkts-no-any-unknown) At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:358:13


                                             3 ERROR: 10605008 ArkTS Compiler Error
                                             Error Message: Use explicit types instead of "any", "unknown" (arkts-no-any-unknown) At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:360:9


                                             4 ERROR: 10605008 ArkTS Compiler Error
                                             Error Message: Use explicit types instead of "any", "unknown" (arkts-no-any-unknown) At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:360:14


                                             5 ERROR: 10605038 ArkTS Compiler Error
                                             Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:366:26


                                             6 ERROR: 10605093 ArkTS Compiler Error
                                             Error Message: Using "this" inside stand-alone functions is not supported (arkts-no-standalone-this) At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:374:30


                                             7 ERROR: 10605093 ArkTS Compiler Error
                                             Error Message: Using "this" inside stand-alone functions is not supported (arkts-no-standalone-this) At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:374:58


                                             8 ERROR: 10605091 ArkTS Compiler Error
                                             Error Message: Destructuring parameter declarations are not supported (arkts-no-destruct-params) At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:378:16


                                             9 ERROR: 10605093 ArkTS Compiler Error
                                             Error Message: Using "this" inside stand-alone functions is not supported (arkts-no-standalone-this) At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:382:20


                                             10 ERROR: 10605093 ArkTS Compiler Error
                                             Error Message: Using "this" inside stand-alone functions is not supported (arkts-no-standalone-this) At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:382:64


                                             11 ERROR: 10605093 ArkTS Compiler Error
                                             Error Message: Using "this" inside stand-alone functions is not supported (arkts-no-standalone-this) At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:384:34


                                             12 ERROR: 10605093 ArkTS Compiler Error
                                             Error Message: Using "this" inside stand-alone functions is not supported (arkts-no-standalone-this) At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:385:34


                                             13 ERROR: 10605093 ArkTS Compiler Error
                                             Error Message: Using "this" inside stand-alone functions is not supported (arkts-no-standalone-this) At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:385:34


                                             14 ERROR: 10605090 ArkTS Compiler Error
                                             Error Message: Function return type inference is limited (arkts-no-implicit-return-types) At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:390:9


                                             15 ERROR: 10605091 ArkTS Compiler Error
                                             Error Message: Destructuring parameter declarations are not supported (arkts-no-destruct-params) At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:390:19


                                             16 ERROR: 10605093 ArkTS Compiler Error
                                             Error Message: Using "this" inside stand-alone functions is not supported (arkts-no-standalone-this) At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:391:42


                                             17 ERROR: 10605093 ArkTS Compiler Error
                                             Error Message: Using "this" inside stand-alone functions is not supported (arkts-no-standalone-this) At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:394:42


                                             18 ERROR: 10605093 ArkTS Compiler Error
                                             Error Message: Using "this" inside stand-alone functions is not supported (arkts-no-standalone-this) At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:397:42


                                             19 ERROR: 10605093 ArkTS Compiler Error
                                             Error Message: Using "this" inside stand-alone functions is not supported (arkts-no-standalone-this) At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:400:42


                                             20 ERROR: 10605093 ArkTS Compiler Error
                                             Error Message: Using "this" inside stand-alone functions is not supported (arkts-no-standalone-this) At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:403:42


                                             21 ERROR: 10605093 ArkTS Compiler Error
                                             Error Message: Using "this" inside stand-alone functions is not supported (arkts-no-standalone-this) At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:406:42


                                             22 ERROR: 10605093 ArkTS Compiler Error
                                             Error Message: Using "this" inside stand-alone functions is not supported (arkts-no-standalone-this) At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:409:28


                                             23 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: ';' expected. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:276:18


                                             24 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: ';' expected. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:277:16


                                             25 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Declaration or statement expected. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:283:11


                                             26 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Unexpected token. A constructor, method, accessor, or property was expected. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:357:5


                                             27 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Identifier expected. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:357:12


                                             28 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Unexpected token. A constructor, method, accessor, or property was expected. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:358:5


                                             29 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Identifier expected. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:358:13


                                             30 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: ',' expected. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:360:13


                                             31 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Declaration expected. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:365:11


                                             32 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: ';' expected. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:366:19


                                             33 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: ';' expected. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:370:29


                                             34 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: ';' expected. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:371:15


                                             35 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Declaration or statement expected. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:376:9


                                             36 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: ',' expected. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:376:23


                                             37 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Identifier expected. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:378:25


                                             38 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: ':' expected. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:378:27


                                             39 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: ';' expected. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:380:29


                                             40 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: ',' expected. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:388:10


                                             41 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: ',' expected. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:388:58


                                             42 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Identifier expected. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:390:34


                                             43 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: ':' expected. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:390:47


                                             44 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Identifier expected. 'this' is a reserved word that cannot be used here. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:390:55


                                             45 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: ':' expected. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:390:59


                                             46 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: ';' expected. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:390:70


                                             47 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Declaration or statement expected. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:390:71


                                             48 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Declaration or statement expected. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:410:7


                                             49 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Declaration or statement expected. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:411:7


                                             50 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Declaration or statement expected. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:418:5


                                             51 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Declaration or statement expected. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:419:5


                                             52 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Declaration or statement expected. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:423:3


                                             53 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Declaration or statement expected. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:424:1


                                             54 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Duplicate identifier '(Missing)'. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:378:24


                                             55 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Duplicate identifier '(Missing)'. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:378:26


                                             56 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Duplicate identifier '(Missing)'. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:390:33


                                             57 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Duplicate identifier '(Missing)'. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:390:47


                                             58 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Duplicate identifier '(Missing)'. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:390:33


                                             59 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Duplicate identifier '(Missing)'. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:390:54


                                             60 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Duplicate identifier '(Missing)'. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:390:33


                                             61 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Duplicate identifier '(Missing)'. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:390:59


                                             62 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Property 'listDirection' does not exist on type 'RowAttribute'. Did you mean 'direction'? At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:279:14


                                             63 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Cannot find name 'width'. Did you mean the instance member 'this.width'? At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:283:12


                                             64 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Function implementation is missing or not immediately following the declaration. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:357:6


                                             65 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Function implementation name must be 'height'. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:360:5


                                             66 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Cannot find name 'buildAddDialog'. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:366:3


                                             67 ERROR: 10905236 ArkTS Compiler Error
                                             Error Message: UI component 'Blank' cannot be used in this place. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:368:7


                                             68 ERROR: 10905236 ArkTS Compiler Error
                                             Error Message: UI component 'Column' cannot be used in this place. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:370:7


                                             69 ERROR: 10905236 ArkTS Compiler Error
                                             Error Message: UI component 'Row' cannot be used in this place. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:371:9


                                             70 ERROR: 10905236 ArkTS Compiler Error
                                             Error Message: UI component 'Text' cannot be used in this place. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:372:11


                                             71 ERROR: 10905236 ArkTS Compiler Error
                                             Error Message: UI component 'Button' cannot be used in this place. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:373:11


                                             72 ERROR: 10905236 ArkTS Compiler Error
                                             Error Message: UI component 'Text' cannot be used in this place. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:379:11


                                             73 ERROR: 10905236 ArkTS Compiler Error
                                             Error Message: UI component 'Row' cannot be used in this place. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:380:11


                                             74 ERROR: 10905236 ArkTS Compiler Error
                                             Error Message: UI component 'Text' cannot be used in this place. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:382:15


                                             75 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: '(Missing)' is an unused renaming of 'placeholder'. Did you intend to use it as a type annotation? At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:390:33


                                             76 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: '(Missing)' is an unused renaming of ''标题（如：高血压复查）''. Did you intend to use it as a type annotation? At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:390:47


                                             77 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: '(Missing)' is an unused renaming of 'text'. Did you intend to use it as a type annotation? At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:390:54


                                             78 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: '(Missing)' is an unused renaming of 'this'. Did you intend to use it as a type annotation? At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:390:59


                                             79 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Cannot find name 'width'. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:390:72


                                             80 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Object is possibly 'undefined'. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:391:42


                                             81 ERROR: 10905236 ArkTS Compiler Error
                                             Error Message: UI component 'TextInput' cannot be used in this place. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:393:9


                                             82 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Object is possibly 'undefined'. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:393:52


                                             83 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Object is possibly 'undefined'. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:394:42


                                             84 ERROR: 10905236 ArkTS Compiler Error
                                             Error Message: UI component 'TextInput' cannot be used in this place. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:396:9


                                             85 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Object is possibly 'undefined'. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:396:50


                                             86 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Object is possibly 'undefined'. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:397:42


                                             87 ERROR: 10905236 ArkTS Compiler Error
                                             Error Message: UI component 'TextInput' cannot be used in this place. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:399:9


                                             88 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Object is possibly 'undefined'. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:399:60


                                             89 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Object is possibly 'undefined'. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:400:42


                                             90 ERROR: 10905236 ArkTS Compiler Error
                                             Error Message: UI component 'TextInput' cannot be used in this place. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:402:9


                                             91 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Object is possibly 'undefined'. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:402:55


                                             92 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Object is possibly 'undefined'. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:403:42


                                             93 ERROR: 10905236 ArkTS Compiler Error
                                             Error Message: UI component 'TextArea' cannot be used in this place. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:405:9


                                             94 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Object is possibly 'undefined'. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:405:51


                                             95 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Object is possibly 'undefined'. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:406:42


                                             96 ERROR: 10905236 ArkTS Compiler Error
                                             Error Message: UI component 'Button' cannot be used in this place. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:408:9


                                             97 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Object is possibly 'undefined'. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:409:28


                                             98 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Cannot find name 'width'. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:411:8


                                             99 ERROR: 10905236 ArkTS Compiler Error
                                             Error Message: UI component 'Blank' cannot be used in this place. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:417:7


                                             100 ERROR: 10505001 ArkTS Compiler Error
                                             Error Message: Cannot find name 'width'. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:419:6


                                             101 ERROR: 10905209 ArkTS Compiler Error
                                             Error Message: Only UI component syntax can be written here. At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/DoctorFollowUpPage.ets:277:17


                                             COMPILE RESULT:FAIL {ERROR:102 WARN:476}

                                             * Try:
                                             > Run with --stacktrace option to get the stack trace.
                                             > Run with --debug option to get more log output.

                                             > hvigor ERROR: BUILD FAILED in 9 s 630 ms

                                             Process finished with exit code -1

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOriginPatterns("*")
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true)
                .maxAge(3600);
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:" + System.getProperty("user.dir") + "/uploads/");
    }

    // 合并所有放行接口，无遗漏、无冲突
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new JwtInterceptor())
                .addPathPatterns("/**")
                .excludePathPatterns(
                        // 用户端
                        "/user/login",
                        "/user/register",
                        "/user/send-code",
                        "/user/info",  // 允许家庭端访问用户信息
                        "/user/*",  // 允许家庭端访问用户详情（如/user/21）
                        // 健康情况和身体情况接口（家庭端需要访问）
                        "/healthCondition/**",
                        "/bodyCondition/**",
                        "/healthRecord/**",
                        // 聊天相关接口
                        "/chat/**",
                        "/message/**",
                        // 患者相关接口
                        "/patients/**",
                        // 管理员端
                        "/admin/login",
                        "/admin/generate-password",
                        "/admin/fix-admin-password",
                        "/admin/verify-password",
                        // 家属/护士/医生端
                        "/family/login",
                        "/nurse/login",
                        "/doctor/login",
                        "/family/**",  // 家属端所有API暂时放行
                        "/nurse/**",   // 护士端所有API暂时放行
                        "/doctor/**",  // 医生端所有API暂时放行（后续可加Token验证）
                        "/api/doctor/**",  // 兼容旧路径
                        // 医疗业务接口（病历、处方等）
                        "/medical/**",  // 医疗相关接口暂时放行
                        // 公共开放接口
                        "/ai/**",
                        "/herbal/**",
                        "/medicine/**",
                        "/medicine-category/**",
                        "/ancient-image/list",
                        "/ancient-image/*",
                        // 康复训练接口
                        "/api/rehab/action/list",
                        "/api/rehab/action/detail/**",
                        "/api/rehab/plan/list",
                        "/api/rehab/plan/detail/**",
                        "/api/rehab/plan/actions/**",
                        "/api/rehab/plan/progress/**",
                        "/api/rehab/plan/recommend/**",
                        // 系统通用
                        "/error",
                        "/uploads/**"
                );
    }

    public static class JwtInterceptor implements HandlerInterceptor {

        @Override
        public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
            // 放行预检请求
            if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
                return true;
            }

            String token = request.getHeader("Token");
            if (token == null || token.isEmpty()) {
                handleUnauthorized(response, "未登录，请先登录");
                return false;
            }

            try {
                // 校验Token是否有效/过期
                if (!JwtUtil.validateToken(token)) {
                    handleUnauthorized(response, "Token已过期，请重新登录");
                    return false;
                }
                // 解析用户信息存入request
                Long userId = JwtUtil.getUserId(token);
                String username = JwtUtil.getUsername(token);
                request.setAttribute("userId", userId);
                request.setAttribute("username", username);
                return true;
            } catch (Exception e) {
                handleUnauthorized(response, "Token无效，请重新登录");
                return false;
            }
        }

        // 统一返回401未授权JSON格式
        private void handleUnauthorized(HttpServletResponse response, String message) throws IOException {
            response.setStatus(401);
            response.setContentType("application/json;charset=UTF-8");
            Map<String, Object> result = new HashMap<>();
            result.put("code", 401);
            result.put("msg", message);
            result.put("data", null);
            ObjectMapper mapper = new ObjectMapper();
            response.getWriter().write(mapper.writeValueAsString(result));
        }
    }
}