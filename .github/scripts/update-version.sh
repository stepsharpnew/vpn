#!/bin/bash
# Скрипт для обновления версий в проекте

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Функция для определения типа версии из названия ветки
detect_version_type() {
    local branch_name=$1
    
    # Паттерны для определения типа версии
    # major: major, breaking, !
    if echo "$branch_name" | grep -qiE '(major|breaking|!)(:|/|-|\s)'; then
        echo "major"
        return
    fi
    
    # minor: feat, feature, minor
    if echo "$branch_name" | grep -qiE '(feat|feature|minor)(:|/|-|\s)'; then
        echo "minor"
        return
    fi
    
    # patch: fix, patch, bug
    if echo "$branch_name" | grep -qiE '(fix|patch|bug)(:|/|-|\s)'; then
        echo "patch"
        return
    fi
    
    # По умолчанию patch
    echo "patch"
}

# Функция для получения следующей версии
get_next_version() {
    local version_type=$1
    
    # Получаем последний тег
    local last_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
    echo "Last tag: $last_tag" >&2
    
    # Убираем префикс 'v' если есть
    local last_version=${last_tag#v}
    
    # Разбиваем версию на части
    IFS='.' read -r major minor patch <<< "$last_version"
    
    case $version_type in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch)
            patch=$((patch + 1))
            ;;
        *)
            echo "Unknown version type: $version_type" >&2
            exit 1
            ;;
    esac
    
    echo "$major.$minor.$patch"
}

# Определяем тип версии из названия ветки или из аргумента
if [ -n "$1" ]; then
    # Если передан аргумент, используем его
    VERSION_TYPE="$1"
else
    # Иначе определяем из названия текущей ветки
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    VERSION_TYPE=$(detect_version_type "$CURRENT_BRANCH")
    echo "Detected version type '$VERSION_TYPE' from branch name: $CURRENT_BRANCH"
fi

# Получаем новую версию
NEW_VERSION=$(get_next_version "$VERSION_TYPE")
TAG="v$NEW_VERSION"

echo "New version: $NEW_VERSION"
echo "Tag: $TAG"

# Обновляем версию в backend/pyproject.toml
if [ -f "$PROJECT_ROOT/backend/pyproject.toml" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/^version = \".*\"/version = \"$NEW_VERSION\"/" "$PROJECT_ROOT/backend/pyproject.toml"
    else
        # Linux
        sed -i "s/^version = \".*\"/version = \"$NEW_VERSION\"/" "$PROJECT_ROOT/backend/pyproject.toml"
    fi
    echo "✓ Updated backend/pyproject.toml to version $NEW_VERSION"
fi

# Обновляем версию в test_app/pubspec.yaml
if [ -f "$PROJECT_ROOT/test_app/pubspec.yaml" ]; then
    BUILD_NUMBER=$(echo "$NEW_VERSION" | cut -d'.' -f3)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/^version: .*/version: $NEW_VERSION+$BUILD_NUMBER/" "$PROJECT_ROOT/test_app/pubspec.yaml"
    else
        # Linux
        sed -i "s/^version: .*/version: $NEW_VERSION+$BUILD_NUMBER/" "$PROJECT_ROOT/test_app/pubspec.yaml"
    fi
    echo "✓ Updated test_app/pubspec.yaml to version $NEW_VERSION+$BUILD_NUMBER"
fi

echo ""
echo "Version updated successfully!"
echo "Next steps:"
echo "  1. Review the changes: git diff"
echo "  2. Commit: git commit -am 'chore: bump version to $TAG'"
echo "  3. Create tag: git tag -a '$TAG' -m 'Release $TAG'"
echo "  4. Push: git push origin main && git push origin '$TAG'"
