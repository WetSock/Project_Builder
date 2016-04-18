
function fillLists(){

    var zxc = multyObj.getSubTasks();
    for(var i = 0; i < zxc.length; i++){
        console.log("append: ", zxc[i]);

        //способы заполнения:
        listProjects.append({name: zxc[i]});
        listMessages.append({name: zxc[i]});
    }
    return true;
}
