EPDeployment deployment = compileAndDeploy(epRuntime,
                "select irstream spolka as X, kursOtwarcia as Y " +
                        "from KursAkcji.win:length(3) ");

//zad.24
EPDeployment deployment = compileAndDeploy(epRuntime,
                "select irstream spolka as X, kursOtwarcia as Y " +
                        "from KursAkcji.win:length(3) " +
                        "where spolka = 'Oracle' ");

//zad.25
EPDeployment deployment = compileAndDeploy(epRuntime,
                "select irstream data, spolka, kursOtwarcia " +
                        "from KursAkcji.win:length(3) " +
                        "where spolka = 'Oracle' ");

//zad.26
EPDeployment deployment = compileAndDeploy(epRuntime,
                "select irstream data, spolka, kursOtwarcia " +
                        "from KursAkcji(spolka='Oracle').win:length(3)");

//zad.27
EPDeployment deployment = compileAndDeploy(epRuntime,
                "select istream data, spolka, kursOtwarcia " +
                        "from KursAkcji(spolka='Oracle').win:length(3)");

//zad.28
EPDeployment deployment = compileAndDeploy(epRuntime,
                "select istream data, spolka, max(kursOtwarcia) " +
                        "from KursAkcji(spolka='Oracle').win:length(5)");

//zad.29
EPDeployment deployment = compileAndDeploy(epRuntime,
                "select istream data, spolka, kursOtwarcia - max(kursOtwarcia) as roznica " +
                        "from KursAkcji(spolka='Oracle').win:length(5)");

//zad.30
EPDeployment deployment = compileAndDeploy(epRuntime,
                "select istream data, spolka, kursOtwarcia - min(kursOtwarcia) as roznica " +
                        "from KursAkcji(spolka='Oracle').win:length(2) " +
                        "having kursOtwarcia - min(kursOtwarcia) > 0");