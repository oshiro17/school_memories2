#!/bin/bash

# ディレクトリ構造を作成
mkdir -p lib/{config,domain,pages/{models,widgets}}

# ファイルを作成
touch lib/config/{color_config.dart,string_config.dart}
touch lib/domain/{class.dart,member.dart,message.dart,ranking.dart,user_profile.dart}
touch lib/pages/{home.dart,login_page.dart,signup_page.dart,class_selection_page.dart,myprofile_page.dart,profile_page.dart,message_page.dart,ranking_page.dart}
touch lib/pages/models/{login_model.dart,signup_model.dart,class_selection_model.dart,myprofile_model.dart,profile_model.dart,message_model.dart,ranking_page_model.dart}
touch lib/pages/widgets/loading_spinner.dart
touch lib/main.dart

echo "プロジェクト構造を作成しました！"

