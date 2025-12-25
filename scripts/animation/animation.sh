
set -e

name=$0
utils="$(dirname $name)/utils.sh"
. $utils

typingspeed=10
shortpause=1
mediumpause=2
longpause=5
scrolllinepause=0.1

ESC="\033"
RESET="$ESC[0m"
PS1="\n$ESC[34m$ $RESET"

slowtype="pv -qL $[$typingspeed+(-2 + RANDOM%5)]"

echo=/bin/echo

setup_video(){
    intro
    repo_setup
    cci_project_init
    secretly_copy_files
    rm -rf force-app/* unpackaged  # we're going to re-create these later.
    add_files_to_git
    investigate_cumulusci_yml
    run_flow
    banner "VOILA!"
    comment "The next video will show how to pull Custom Objects and Fields from the org."
    secretly_deploy_from_other_repo
}

# video 2 depends on a dev scratch org existing
retrieve_changes_video(){
    banner "Retrieving Org Changes"
    setup_everything_as_video_1_would
    retrieve_changes
    banner "TADA!"
    comment "The next video will show how to populate the org with sample data."
}

populate_data_video(){
    banner "Populating Sample Data"
    setup_everything_as_video_2_would
    new_dev_org
    fake_populate_data
    secretly_deploy_from_other_repo
    extract_dataset_from_org
    banner "PRESTO!"
    comment "The next video will show how we can make it easy for QA to spin up testing orgs."
}

qa_org_video(){
    banner "Customizing Flows"
    setup_everything_as_video_3_would
    # switch_to_qa_org
    change_qa_org_flow
    run_qa_org_flow
    comment "Now the QA rep can log in"
    fakedo 'cci org browser'
    poof "We're ready for testing -- with data -- in the Salesforce UI"
    comment "Or -- if we've got chromedriver installed -- maybe we could let a robot do some of the testing in a web browser:"
    typedo 'cci task run robot'
    banner "SHAZAM!"
    fakedo "(And of course, we can delete the org when we're done: 'cci org scratch_delete qa')"
    comment "Thank you for watching this video series!"
}

snowfakery_video(){
    banner "Faked Data with Snowfakery"
    setup_everything_as_video_3_would
    cci task run delete_data --org qa --objects "Entitlement,Account" > /dev/null
    comment "Let's make some data with Snowfakery"
    comment "We'll start with simple 'static' data"
    comment "To do that, we will edit a 'recipe' in any text editor or IDE"
    comment "Most people use VSCode, but vim is easier for this demo."

    append_lines datasets/recipe.yml ../recipe_1.txt
    comment "Let's do a 'dry run' without CumulusCI or Salesforce"
    typedo "snowfakery datasets/recipe.yml"
    comment "Great! Now let's try a real data load into the org 'qa' using CumulusCI (cci) "
    typedo "cci task run snowfakery --recipe datasets/recipe.yml --org qa"
    comment "Let's see if it worked! CCI can pull a list of all accounts from the org."
    typedo 'cci task run query --object Account --query "Select Id,Name from Account" --result_file Accounts.csv --org qa'
    typedo 'cat Accounts.csv'
    comment "Now let's add some randomized contacts"
    append_lines datasets/recipe.yml ../recipe_2.txt
    comment "Dry run, then loading into CCI"
    typedo "snowfakery --recipe datasets/recipe.yml"
    typedo "cci task run snowfakery --recipe datasets/recipe.yml --org qa"
    comment "Let's check those too."
    typedo 'cci task run query --object Contact --query "Select Id,FirstName,LastName,MailingCountry from Contact" --result_file Contacts.csv --org qa'
    typedo 'cat Contacts.csv'
    comment 'Custom objects and fields are just as easy as to generate.'
    # etc. etc.
    comment 'Relationships are an important aspect too!'
    banner "BOOYAH!"
}

everything(){
    setup_video
    retrieve_changes_video
    populate_data_video
    qa_org_video
    snowfakery_video
}



intro(){
    banner "CumulusCI"
    sleep $mediumpause
    clear
    comment "Let's make a project from scratch"
    sleep $mediumpause
}

repo_setup(){
    typedo "mkdir Food-Bank"
    typedo "cd Food-Bank"
    cd Food-Bank  # just in case...shell weirdness
    typedo "git init"
}

cci_project_init(){
    comment "We'll ask CCI to set up a project with most options 'defaulted'"
    fakedo "cci project init"

    pretend_interact "$ESC[34m# Project Info$RESET
    \nThe following prompts will collect general information about the project
    \n
    \nEnter the project name.  The name is usually the same as your repository name.
    \nNOTE: Do not use spaces in the project name!
    \n$ESC[1mProject Name$RESET [Project]: "   " Food-Bank"


    pretend_interact  "CumulusCI uses an unmanaged package as a container for your project's metadata.
    \nEnter the name of the package you want to use.
    \n$ESC[1mPackage Name$RESET [Project]:"     "Food-Bank"

    pretend_interact "\n$ESC[1mIs this a managed package project? [y/N]:$RESET " "N"

    pretend_interact "\n$ESC[1mSalesforce API Version [48.0]:$RESET "  " "

    pretend_interact "Salesforce metadata can be stored using Metadata API format or DX source format. Which do you want to use?
    \n$ESC[1mSource format$RESET (sfdx, mdapi) [sfdx]:"   "sfdx"

    pretend_interact "$ESC[34m # Extend Project$RESET
    \nCumulusCI makes it easy to build extensions of other projects configured for CumulusCI like Salesforce.org's NPSP and EDA.  If you are building an extension of another project using CumulusCI and have access to its Github repository, use this section to configure this project as an extension.
    \n$ESC[1mAre you extending another CumulusCI project such as NPSP or EDA?$RESET [y/N]: "   "  "

    pretend_interact "$ESC[34m # Git Configuration$RESET
    \n
    \nCumulusCI assumes your default branch is master, your feature branches are named feature/*, your beta release tags are named beta/*, and your release tags are release/*.  If you want to use a different branch/tag naming scheme, you can configure the overrides here.  Otherwise, just accept the defaults.
    $ESC[1mDefault Branch$RESET [master]: "  "  "

    pretend_interact "$ESC[1mFeature Branch Prefix$RESET [feature/]: "  " "

    pretend_interact "$ESC[1mBeta Tag Prefix$RESET [beta/]: "   " "

    pretend_interact "$ESC[1mRelease Tag Prefix$RESET [release/]: "   " "

    pretend_interact "$ESC[34m# Apex Tests Configuration$RESET
    \nThe CumulusCI Apex test runner uses a SOQL where clause to select which tests to run.  Enter the SOQL pattern to use to match test class names.
    $ESC[1mTest Name Match [%_TEST%]:$RESET" " "

    pretend_interact "$ESC[1mDo you want to check Apex code coverage when tests are run?$RESET [Y/n]:" "Y"

    pretend_interact "$ESC[1mMinimum code coverage percentage$RESET [75]:" "" 

    echo -e "$ESC[32mYour project is now initialized for use with CumulusCI$RESET"
    echo
}

secretly_copy_files(){
    # cp -r ../CCI-Food-Bank/* .
    # cp -rf ../CCI-Food-Bank/.git* .

    # cp ../cumulusci.yml cumulusci.yml
    git init >> ../secret.log || true   # ignore failure
    cp -rf ../CCI-Food-Bank/.gitignore .
    rm cumulusci.yml
    echo -e "Food-Bank\nFood-Bank\n\n\n\n\n\n\n\n\n\n\n\n\n\n" | cci project init >> ../secret.log | true   # ignore failure
    # rm -rf robot/CCI-Food-Bank
}

add_files_to_git(){
    typedo 'ls'
    typedo 'git add --all'
    typedo 'git status'
    typedo 'git commit -m "Initial Configuration for Food-Bank App"'
}

investigate_cumulusci_yml(){
    comment "CumulusCI's main configuration file is cumulusci.yml."
    comment "Let's look at the one 'cci project init' created for us"
    fakedo 'vim cumulusci.yml'
    vim cumulusci.yml -c "source ../cat_file.vim"
}

run_flow(){
    comment "A newly initialized CCI project includes several scratch org templates, ready to go."
    typedo 'cci org list'
    comment "We can make dev the default scratch org for convenience"
    typedo 'cci org default dev'
    comment "We can spin up a scratch org with a flow, which configures it, loads metadata and data"
    comment "Let's see what flows we have available..."
    typedo 'cci flow list' 
    comment "That's a lot of built-in flows! Let's look closer at one of them."
    typedo 'cci flow info dev_org'
    comment "dev_org looks like it will do the things we want."
    typedo 'cci flow run dev_org' 
    comment "We can take a look at our org in a web browser:"
    fakedo 'cci org browser'
    poof "CCI would log you into the Scratch Org's Salesforce UI."
    comment "And that's how we would setup a project and a scratch org in CumulusCI!"
}

secretly_deploy_from_other_repo(){
    # deploy from another repo to simulate user edits
    pushd ../CCI-Food-Bank >> ../secret.log
    cci flow run dev_org >> ../secret.log
    cci task run load_dataset >> ../secret.log
    popd >> ../secret.log
}

retrieve_changes(){
    typedo "cci org default dev"
    comment "Food banks need to track deliveries. So offscreen we created Delivery__c and Delivery_Item__c using Salesforce's Setup UI."
    comment "Now we want to pull those changes into git. We'll start by looking for a task that can summarize our org changes. "
    comment "CCI can list all of its available tasks:"
    typedo "cci task list" 
    comment "That's a lot. And, by the way, you can add your own tasks if you want!"
    comment "Let's use grep to search for something specific"
    typedo "cci task list | grep changes" 
    typedo "cci task info list_changes | head"
    comment "That's the one we want!"
    typedo "cci task run list_changes"
    typedo 'cci task run retrieve_changes'
    typedo 'git status'
    typedo 'git add force-app'
    typedo 'git commit -m "Initial schema for delivery tracking"'
    comment "We're done with this scratch org, and all of our metadata has been saved to git. We can safely delete it!"
    typedo 'cci org scratch_delete dev'
}

new_dev_org(){
    comment "Let's see how easily a teammate could spin up a new org from the repo"
    typedo 'cci org default dev'
    typedo 'cci flow run dev_org' 
}

fake_populate_data(){
    comment "The captured Delivery__c and Delivery_Item__c objects are now in the new org."
    comment "Now the teammate could use the Salesforce UI to create some sample data records."
    fakedo 'cci org browser'
    poof "CCI would launch a web browser and log the teammate in."
}

extract_dataset_from_org(){
    comment "We created some records off-screen. Let's pull them down and use them as sample data."
    comment "CumulusCI uses a mapping file to figure out which objects and fields to extract and load."
    comment "Rather than write one from scratch, though, we can also ask CumulusCI to infer one from our org:"
    typedo 'cci task info generate_dataset_mapping | head'
    comment "Looks useful? Let's run it:"
    typedo 'cci task run generate_dataset_mapping'
    comment "Then we extract the actual data:"
    typedo 'cci task run extract_dataset'
    typedo 'ls datasets'
    fakedo 'vim datasets/sample.sql'
    vim datasets/sample.sql -c "source ../cat_file.vim"
    comment "Looks like real data! Let's save it for later."
    sleep $mediumpause
    typedo 'git add datasets'
    typedo 'git commit -m "Add sample data"'
    typedo 'cci org scratch_delete dev'
}

switch_to_qa_org(){
    comment "Let's start working with a different org, as a QA person might"
    typedo 'cci org default qa'
}

append_lines(){
    local filename="$1"
    local newtext="$2"
    local function_call="call AppendLines(readfile('$2'))"

    vim $filename -c "source ../append_util.vim" -c "$function_call"
}

change_qa_org_flow(){
    comment "We should check whether the qa_org flow will load the dataset. Test data is helpful for QA testers!"
    typedo 'cci flow info qa_org'
    comment "It turns out no: load_dataset is not one of the steps in the flow"
    comment "The flow is generated in two different places. CumulusCI has a bunch of steps built-in to it."
    comment "We can also extend them in our own cumulusci.yml"
    comment "Let's change the flow (through its config_qa subflow) by editing cumulusci.yml ."
    fakedo "vim cumulusci.yml"
    sleep $shortpause
    append_lines cumulusci.yml "../append_task_code.txt"
    reset
    comment "Let's save our work"
    typedo "git add cumulusci.yml"
    typedo 'git commit -m "Added to qa_org flow"'
    typedo "cci flow info qa_org"
    comment "Now step 3.3 is load_dataset! We're ready for testing!"
    comment "We could also have created a brand new flow, or new tasks."
}

run_qa_org_flow(){
    typedo "cci flow run qa_org" 
    comment  "The QA org now has the captured metadata and dataset loaded automatically!"
}

setup_files(){
    # verify we're in the right directory and have the right helper files available
    ls CCI-Food-Bank/ > /dev/null
    ls "cumulusci.yml" > /dev/null
    ls "append_util.vim" > /dev/null
    ls "append_task_code.txt" > /dev/null

    mkdir -p Food-Bank
    cd Food-Bank
    git init >> ../secret.log
    secretly_copy_files
}
setup_everything_as_video_1_would(){
    setup_files
    cci org default dev >> ../secret.log
    secretly_deploy_from_other_repo
}

setup_everything_as_video_2_would(){
    setup_files
    ls force-app/* > /dev/null # double-check these files are here
}

setup_everything_as_video_3_would(){
    setup_files
    cp -rfv ../CCI-Food-Bank/force-app/* ./force-app/ >> ../secret.log
    cp -rfv ../CCI-Food-Bank/datasets/* ./datasets  >> ../secret.log
    ls force-app/* > /dev/null # double-check these files are here
}

eval $1
